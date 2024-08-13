(in-package :crdt-lisp/cluster/store)

(defparameter *ae* (ae:make-store))

(defparameter *ae-queue* (make-instance 'tsq:tsq))

(defparameter *ae-reader* nil)

(defparameter *clock* (h:zero))

(defparameter *clock-lock* (th:make-lock))

(defparameter *node* (make-node-id))

(defun send-time ()
  (th:acquire-lock *clock-lock*)
  (let ((ts (h:send *clock*)))
    (setq *clock* ts)
    (th:release-lock *clock-lock*)
    (h:hulc-string ts *node*)))

(defun recv-time (&rest hulcs)
  (let ((hulc (reduce #'h:hulc-max hulcs)))
    (th:acquire-lock *clock-lock*)
    (let ((ts (h:recv *clock* hulc)))
      (setq *clock* ts)
      (th:release-lock *clock-lock*)
      (h:hulc-string ts *node*))))

(defun make-ae-req ())

(defun make-ae-res (request))

(defun recv-ae-res (request) (recv-ae request))

(defun put-ae (key item)
  (just-put-ae key (send-time) item))

(defun just-put-ae (key ts item)
  (tsq:tsq-push *ae-queue* (list key ts item))
  ts)

(defun recv-ae (items)
  (let ((ts (recv-time (mapcar #'caar items))))
    (mapcan (lambda (item)
              (apply #'just-put-ae item))
            items)
    ts))

(defun get-ae (key)
  (ae:fetch *ae* key))

(defun ae-reader ()
  (loop do
    (setq *ae* (apply #'ae:put *ae* (tsq:tsq-pop *ae-queue*)))))

(defun start-store! ()
  (th:start-multiprocessing)
  (setq *ae-reader* (th:make-thread #'ae-reader)))

(defun stop-store! ()
  (th:destroy-thread *ae-reader*)
  (setq *ae-reader* nil))
