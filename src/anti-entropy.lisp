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
  (-<>> (concatenate '(vector (unsigned-byte 8))
                     (key-octets key)
                     (hulc-octets hulc))
        (ironclad:digest-sequence :sha256)
        (octets->bit-vector)))

(defun octets->bit-vector (octets)
  (cl-intbytes:octets->int octets (length octets)))

(let* ((t0 (crdt-lisp/hlc:send (crdt-lisp/hlc:zero)))
       (n0 (crdt-lisp/node-id:make-node-id))
       (h0 (crdt-lisp/hlc:hulc-string t0 n0)))
  (hash-xor (hash-one "foo" h0)
            (hash-one "foo" h0)))

(defun hash-xor (a b)
  (bit-xor a b))
