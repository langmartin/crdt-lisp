(in-package :crdt-lisp/cluster/send)

(defparameter *send-queue* (make-instance 'tsq:tsq))

(defun pack (message)
  (marshal:marshal message))

(defun unpack (message)
  (marshal:unmarshal message))

(defun send (type message)
  (tsq:tsq-push *send-queue* (pack (cons type message))))

(defun send-pop ()
  (tsq:tsq-pop *send-queue*))
