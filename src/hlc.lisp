(in-package :crdt-lisp-hlc)

(defstruct hlc time tick)

(defun send (hlc system-clock)
  (let ((time (max (hlc-time hlc)
                   (funcall system-clock))))
    (make-hlc
     :time time
     :tick (if (= time (hlc-time hlc))
               (+ 1 (hlc-tick hlc))
               0))))

(defun recv (hlc message-hlc system-clock)
  (let ((time (max (hlc-time hlc)
                   (hlc-time message-hlc)
                   (funcall system-clock))))
    (make-hlc
     :time time
     :tick (cond ((and (= time (hlc-time hlc))
                       (= time (hlc-time message-hlc)))
                  (+ 1 (max (hlc-tick hlc)
                            (hlc-tick message-hlc))))

                 ((= time (hlc-time hlc))
                  (+ 1 (hlc-tick hlc)))

                 ((= time (hlc-time message-hlc))
                  (+ 1 (hlc-tick message-hlc)))

                 (t 0)))))
