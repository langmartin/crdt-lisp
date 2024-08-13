(in-package :crdt-lisp/cluster)

(defparameter *cluster* nil)
(defparameter *cluster-lock* (th:make-lock))

(defstruct cluster name listen bootstrap node-id hlc peer-connections handler)

(defun join-cluster! (&key name listen bootstrap (handler #'dispatch))
  (->> (make-cluster :name name
                     :listen listen
                     :bootstrap bootstrap
                     :hlc (crdt-lisp/hlc:zero)
                     :peer-connections '()
                     :handler handler)
       (start-server!)
       (connect-bootstrap!)
       (setq *cluster*)))

(defun send-cluster (c message)
  (mapcan (lambda (peer-socket)
            (zmq:send (cdr peer-socket) message))
          (cluster-peer-connections c)))

(defun dispatch (message)
  (case (car message)
    (('item) (st:recv-ae (cdr message)))
    (('ae-response) (st:recv-ae-res (cdr message)))
    (('ae-request)
     (->> (st:make-ae-res (cdr message))
          (marshal:marshal)
          (send-cluster *cluster*)))))

(defun cluster-add-peer (c peer socket)
  (make-cluster :name (cluster-name c)
                :listen (cluster-listen c)
                :bootstrap (cluster-bootstrap c)
                :hlc (cluster-hlc c)
                :peer-connections (cons (cons peer socket)
                                        (cluster-peer-connections c))
                :handler (cluster-handler c)))

(defun cluster-add-peer! (peer socket)
  (th:acquire-lock *cluster-lock*)
  (let ((c (cluster-add-peer *cluster* peer socket)))
    (setq *cluster* c)
    (th:release-lock *cluster-lock*)
    c))

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
