(in-package :crdt-lisp-hlc)

(defstruct hlc time tick)

(defun send (hlc system-clock)
  (let ((time (max (hlc-time hlc)
                   (funcall #'system-clock))))
    (if (= time logical-time)
        (make-hlc logical-time (+ 1 (hlc-tick hlc)))
        (make-hlc physical-time 0))))
