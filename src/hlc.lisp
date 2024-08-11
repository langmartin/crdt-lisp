(in-package :crdt-lisp/hlc)

(defstruct hlc time tick)

(defun zero (&optional (system-clock #'default-system-clock))
  (make-hlc :time (funcall system-clock 0)
            :tick 0))

(defun send (hlc &optional (system-clock #'default-system-clock))
  (let ((time (max (hlc-time hlc)
                   (funcall system-clock (hlc-time hlc)))))
    (make-hlc :time time
              :tick (if (= time (hlc-time hlc))
                        (+ 1 (hlc-tick hlc))
                        0))))

(defun recv (hlc message-hlc &optional (system-clock #'default-system-clock))
  (let ((time (max (hlc-time hlc)
                   (hlc-time message-hlc)
                   (funcall system-clock (hlc-time hlc)))))
    (make-hlc :time time
              :tick (cond ((and (= time (hlc-time hlc))
                                (= time (hlc-time message-hlc)))
                           (+ 1 (max (hlc-tick hlc)
                                     (hlc-tick message-hlc))))

                          ((= time (hlc-time hlc))
                           (+ 1 (hlc-tick hlc)))

                          ((= time (hlc-time message-hlc))
                           (+ 1 (hlc-tick message-hlc)))

                          (t 0)))))

(defun unix-milliseconds (hlc)
  (hlc-time hlc))

(defun default-system-clock (_last)
  (declare (ignore _last))
  (let* ((lt (local-time:now))
         (s (local-time:timestamp-to-unix lt))
         (ms (local-time:timestamp-millisecond lt)))
    (+ (* 1000 s) ms)))
