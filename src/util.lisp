(in-package :crdt-lisp/util)

(defun b64 (bytes)
  (with-output-to-string (out)
    (s-base64:encode-base64-bytes bytes out)))

(defun b64-trim (bytes)
  (->> (with-output-to-string (out)
         (s-base64:encode-base64-bytes bytes out))
       (string-right-trim "=")))

(let ((bs (cl-intbytes:int64->octets 812341234)))
  (with-output-to-string (out)
    (-> bs
        (cl-octet-streams:make-octet-input-stream)
        (s-base64:encode-base64 out))))

(defun unb64 (padded-b64-str)
  (with-input-from-string (in padded-b64-str)
    (s-base64:decode-base64-bytes in)))

(defun unb64-fix (unpadded-b64-str)
  (with-input-from-string (in (fix-padding unpadded-b64-str))
    (s-base64:decode-base64-bytes in)))

(defun fix-padding (str)
  (case (length str)
    (11 (concatenate 'string str "="))
    (22 (concatenate 'string str "=="))
    (T str)))

(defun split-while (pred lst)
  (split-while* pred nil lst))

(defun split-while* (pred yes lst)
  (if (or (null lst)
          (not (funcall pred (car lst))))
      (list (nreverse yes) lst)
      (split-while* pred
                    (cons (car lst) yes)
                    (cdr lst))))

(defmacro fn1 (formal &rest body)
  (let ((x (gensym)))
    `(lambda (,x)
       (destructuring-bind ,formal
           ,x
         ,@body))))
