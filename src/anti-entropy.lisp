(in-package :crdt-lisp/anti-entropy)

(defun make-store ()
  (empty-map))

(defun put (store key hlc value)
  (let ((prev (fetch-pair store key)))
    (if (or (not prev)
            (h:lt? (car prev) hlc))
        (fset:map ($ store) (key (cons hlc value)))
        store)))

(defun fetch-pair (store key)
  (lookup store key))

(defun fetch (store key)
  (let ((pair (fetch-pair store key)))
    (if (not pair)
        nil
        (cdr pair))))

(defun key-octets (key)
  (-> (cond ((stringp key) key)
            ((listp key) (format nil "~{~A~}" key)))
      (babel:string-to-octets)))

(defun hulc-octets (hulc-string)
  (u:unb64 hulc-string))

(defun hash-one (key hulc)
  (->> (concatenate '(vector (unsigned-byte 8))
                    (key-octets key)
                    (hulc-octets hulc))
       (ironclad:digest-sequence :sha256)
       (octets->int)))

(defun octets->int (octets)
  (cl-intbytes:octets->int octets (length octets)))

(defun hash-xor (&rest hashes)
  (reduce #'logxor hashes))

(defun hash-n-bytes (hash)
  (-> hash integer-length (/ 8) ceiling))

(defun hash-string (hash)
  (with-output-to-string (out)
    (-> hash
        (cl-intbytes:int->octets (hash-n-bytes hash))
        (s-base64:encode-base64-bytes out))))
