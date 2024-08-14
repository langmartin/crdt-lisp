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
  (start-subscriber! (cluster-bootstrap *cluster*)))

;;; TODO maybe a cluster/recv package?
(defun dispatch (message)
  (case (car message)
    (('item) (st:recv-ae (cdr message)))
    (('ae-response) (st:recv-ae (cdr message)))
    (('ae-request) (st:recv-ae-req (cdr message)))
    (('connect) (start-subscriber! (cadr message)))
    (t
     ;; TODO logging
     t)))

(defun cluster-add-peer (c peer socket)
  (make-cluster :name (cluster-name c)
                :listen (cluster-listen c)
                :bootstrap (cluster-bootstrap c)
                :hlc (cluster-hlc c)
                :peer-connections (cons (cons peer socket)
                                        (cluster-peer-connections c))
                :handler (cluster-handler c)))

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

(defun start-server! (c)
  (zmq:with-context (ctx)
    (zmq:with-socket (socket ctx 'zmq:rep)
      (zmq:bind socket (cluster-listen c))
      (loop
        (let ((query (make-instance 'zmq:msg)))
          (zmq:recv socket query)
          (funcall (cluster-handler c) query))
        (zmq:send socket (make-instance 'zmq:msg :data "OK"))))))

(defun connect-bootstrap! (c)
  (zmq:with-context (ctx)
    (zmq:with-socket (socket ctx 'zmq:req)
      (let ((peer (cluster-bootstrap c)))
        (zmq:connect socket peer)
        (cluster-add-peer c peer socket)))))
