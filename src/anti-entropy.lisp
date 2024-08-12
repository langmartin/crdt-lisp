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
