(in-package :crdt-lisp/schema)

(defstruct envelope message hulc)

(defun messagep (message)
  (or (envelope-p message)
      (hlc-p message)
      (case (car message)
        (('HELLO) (and (stringp (cadr message)))))))

(defun to-network (message)
  (prin1-to-string
   (cond ((envelope-p message)
          '(ENV
            (to-network (envelope-hulc message))
            (to-network (envelope-message message))))
         ((hlc-p message)
          '(HLC (hlc-time message) (hlc-tick message)))
         (t message))))

(defun to-lisp (binary)
  (let ((obj (read-from-string binary)))
    (case (car obj)
      ((ENV) (make-envelope :hulc (to-lisp (cadr obj)) :message (to-lisp (caddr obj))))
      ((HLC) (make-hlc :time (cadr obj) :tick (caddr obj)))
      ((HELLO) obj)
      (t nil))))
