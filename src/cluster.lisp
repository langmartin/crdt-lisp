(in-package :crdt-lisp/cluster)

(defparameter *cluster* nil)
(defparameter *cluster-lock* (th:make-lock))

(defstruct cluster name listen bootstrap node-id hlc peer-connections handler)

(defun tcp// (str)
  (concatenate 'string "tcp://" str))

(defun join-cluster! (&key name listen bootstrap (handler #'dispatch))
  (setq *cluster*
        (make-cluster :name name
                      :listen (tcp// listen)
                      :bootstrap (tcp// bootstrap)
                      :hlc (crdt-lisp/hlc:zero)
                      :peer-connections '()
                      :handler handler))
  (start-publisher!)
  (start-subscriber! (cluster-bootstrap *cluster*))
  (start-connection-timer!)
  *cluster*)

;;; TODO maybe a cluster/recv package?
(defun dispatch (message)
  (case (car message)
    (('item) (st:recv-ae (cdr message)))
    (('ae-response) (st:recv-ae (cdr message)))
    (('ae-request) (st:recv-ae-req (cdr message)))
    (('connect)
     (let ((peer (cadr message)))
       (if (not (cluster-has-peer? *cluster* peer))
           (start-subscriber! peer))))
    (t
     ;; TODO logging
     t)))

;; https://stackoverflow.com/questions/38421721/returning-a-new-structure-with-fields-changed
(defun update-struct (struct &rest bindings)
  (loop
    with copy = (copy-structure struct)
    for (slot value) on bindings by #'cddr
    do (setf (slot-value copy slot) value)
    finally (return copy)))

(defun cluster-add-peer (c peer)
  (update-struct c
                 :peer-connections
                 (cons peer (cluster-peer-connections c))))

(defun cluster-has-peer? (c peer)
  (not (null (member peer (cluster-peer-connections c)))))

(defun start-publisher (c)
  (zmq:with-context (ctx)
    (zmq:with-socket (socket ctx :pub)
      (zmq:bind socket (cluster-listen c))
      (loop
        (let ((message (send::send-pop)))
          (->> (make-instance 'zmq:msg :data message)
               (zmq:send socket))))))
  c)

(defun start-subscriber (c peer)
  (zmq:with-context (ctx)
    (zmq:with-socket (socket ctx :sub)
      (zmq:setsockopt socket 'zmq:subscribe "")
      (zmq:connect socket peer)
      (loop
        (let ((message (make-instance 'zmq:msg)))
          (zmq:recv socket message)
          (dispatch (send::unpack message))))))
  (cluster-add-peer c peer))

(defun start-publisher! ()
  (th:with-lock-held (*cluster-lock*)
    (->> *cluster*
         (start-publisher)
         (setq *cluster*))))

(defun start-subscriber! (peer)
  (th:with-lock-held (*cluster-lock*)
    (-<>> *cluster*
          (start-subscriber <> peer)
          (setq *cluster*))))

(defun republish-connections ()
  (th:with-lock-held (*cluster-lock*)
    (mapc (lambda (peer)
            (send:send 'connection peer))
          (cluster-peer-connections *cluster*))))

(defun start-connection-timer! ()
  (-> (sb-ext:make-timer #'republish-connections :name :cluster-republish-connections)
      (sb-ext:schedule-timer 59)))
