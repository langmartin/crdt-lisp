(in-package :crdt-lisp/anti-entropy)

(defun make-store ()
  (fset:empty-map))

(defun put (store key hlc value)
  (let ((prev (fetch-pair store key)))
    (if (or (not prev)
            (string-lessp (car prev) hlc))
        (fset:map ($ store) (key (cons hlc value)))
        store)))

(defun fetch-pair (store key)
  (fset:lookup store key))

(defun fetch (store key)
  (let ((pair (fetch-pair store key)))
    (if (not pair)
        nil
        (cdr pair))))

;;; ========================================================================
;;; Hash key-hulc pairs and xor them together

(defun key-octets (key)
  (-> (cond ((stringp key) key)
            ((listp key) (format nil "~{~A~}" key)))
      (babel:string-to-octets)))

(defun hulc-octets (hulc-string)
  (unb64 hulc-string))

(defun hash-one (item)
  (->> (concatenate '(vector (unsigned-byte 8))
                    (key-octets (car item))
                    (hulc-octets (cadr item)))
       (ironclad:digest-sequence :sha256)
       (octets->int)))

(defun octets->int (octets)
  (cl-intbytes:octets->int octets (length octets)))

(defun hash-xor (hashes)
  (reduce #'logxor hashes))

(defun hash-n-bytes (hash)
  (-> hash integer-length (/ 8) ceiling))

(defun hash-string (hash)
  (if (null hash)
      ""
      (with-output-to-string (out)
        (-> hash
            (cl-intbytes:int->octets (hash-n-bytes hash))
            (s-base64:encode-base64-bytes out)))))

;;; ========================================================================
;;; Divide up the local store and represent the pages as hash buckets

(defun hlc-buckets (starting-ms bucket-ms bucket-count)
  (if (= bucket-count 1)
      (list (hlc-bucket-str 0))
      (let ((end (- starting-ms (mod starting-ms bucket-ms))))
        (cons (hlc-bucket-str end)
              (hlc-buckets end (* bucket-ms 2) (- bucket-count 1))))))

(defun default-buckets ()
  (hlc-buckets (h::default-system-clock nil)
               60000
               9))

(defun hlc-bucket-str (time)
  (h:hulc-string (h:make-hlc :time time :tick 0) (n:epoch-node-id)))

(defun bucket-sort (store)
  (sort (fset:convert 'list store)
        (lambda (a b)
          (string-lessp (cadr a) (cadr b)))))

(defun bucket-group (sorted-items buckets)
  (if (null buckets)
      '()
      (destructuring-bind (ours tail)
          (split-while (lambda (item)
                         ;; less is older, the bucket is older than
                         ;; the items in it
                         (string-lessp (car buckets) (cadr item)))
                       sorted-items)
        (cons (cons (car buckets) ours)
              (bucket-group tail (cdr buckets))))))

(defun hash-partitions (grouped)
  (mapcar (lambda (pair)
            (let ((bucket (car pair))
                  (items (cdr pair)))
              (cons bucket
                    (->> items (mapcar #'hash-one) hash-xor hash-string))))
          grouped))

(defun make-request (store &optional (buckets (default-buckets)))
  (-> store bucket-sort (bucket-group buckets) hash-partitions))
