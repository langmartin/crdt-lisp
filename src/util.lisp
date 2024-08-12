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

(defun b64->8-octets (b64string)
  (let ((str (concatenate 'string b64string "=")))
    (with-input-from-string (in str)
      (s-base64:decode-base64-bytes in))))
