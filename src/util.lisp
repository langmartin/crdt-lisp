(in-package :crdt-lisp/util)

(defun b64 (bytes)
  (->> (with-output-to-string (out)
         (s-base64:encode-base64-bytes bytes out))
       (string-right-trim "=")))

(let ((bs (cl-intbytes:int64->octets 812341234)))
  (with-output-to-string (out)
    (-> bs
        (cl-octet-streams:make-octet-input-stream)
        (s-base64:encode-base64 out))))

(defun unb64 (unpadded-b64-str)
  (with-input-from-string (in (fix-padding unpadded-b64-str))
    (s-base64:decode-base64-bytes in)))

(defun fix-padding (str)
  (case (length str)
    (11 (concatenate 'string str "="))
    (22 (concatenate 'string str "=="))))
