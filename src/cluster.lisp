(in-package :crdt-lisp/cluster)

(defstruct cluster name listen connect node-id hlc peer-connections handler)

(defun join-cluster (&key name listen connect handler)
  (-> (make-cluster :name name
                    :listen listen
                    :connect connect
                    :hlc (crdt-lisp/hlc:zero)
                    :peer-connections '()
                    :handler handler)
      (start-server)
      (connect-bootstrap)))

(defun send (c message)
  (mapcan (lambda (peer-socket)
            (zmq:send (cdr peer-socket) message))
          (cluster-peer-connections c)))

(defun cluster-add-peer (c peer socket)
  (make-cluster :name (cluster-name c)
                :listen (cluster-listen c)
                :connect (cluster-connect c)
                :hlc (cluster-hlc c)
                :peer-connections (cons (cons peer socket)
                                        (cluster-peer-connections c))
                :handler (cluster-handler c)))

(defun start-server! (c)
  (zmq:with-context (ctx)
    (zmq:with-socket (socket ctx 'zmq:rep)
      (zmq:bind socket (cluster-listen c))
      (loop
        (let ((query (make-instance 'zmq:msg)))
          (zmq:recv socket query)
          (funcall (cluster-handler c) query))
        (zmq:send socket (make-instance 'zmq:msg :data "OK"))))))

(defun connect-bootstrap (c)
  (zmq:with-context (ctx)
    (zmq:with-socket (socket ctx 'zmq:req)
      (let ((peer (cluster-connect c)))
        (zmq:connect socket peer)
        (cluster-add-peer c peer socket)))))
