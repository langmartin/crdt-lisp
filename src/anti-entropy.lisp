(in-package :crdt-lisp/anti-entropy)

(defun make-store ()
  (fset:empty-map))

(defun put (store key hlc value)
  (let ((prev (fetch-pair store key)))
    (if (or (not prev)
            (h:lt? (car prev) hlc))
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

;;; ========================================================================
;;; Divide up the local store and represent the pages as hash buckets

(defun hlc-buckets (starting-ms bucket-ms bucket-count)
  (if (= bucket-count 1)
      (list (hlc-bucket-str 0))
      (let ((end (- starting-ms (mod starting-ms bucket-ms))))
        (cons (hlc-bucket-str end)
              (hlc-buckets end (* bucket-ms 2) (- bucket-count 1))))))

(defun hlc-bucket-str (time)
  (h:hulc-string (h:make-hlc :time time :tick 0) (n:epoch-node-id)))

(hlc-buckets 6 2 2)

(defun bucket-sort (store)
  (-> store
      (fset:stable-sort
       (lambda (a b)
         (string-lessp (caar a) (caar b))))
      (bucket-group
       (hlc-buckets (h::default-system-clock nil) 60000 9))))

;;; take-while lt
;;; again

(bucket-sort (make-store))

(defun bucket-group0 (sorted-items buckets)
  (let ((split (split-sequence:split-sequence-if
                (lambda (item)
                  (string-lessp (caar item) (car buckets))
                  sorted-items
                  :count 2))))
    (if (fset:empty? (cadr split))
        '()
        (cons (cons (car buckets)
                    (car split))
              (bucket-group (cadr split) (cdr buckets))))))

(defun bucket-group (sorted-items buckets)
  (if (null buckets)
      '()
      (let* ((split (split-while
                     (lambda (item)
                       (string-lessp (caar item) (car buckets)))
                     sorted-items))
             (ours (car split))
             (tail (cadr split)))
        (cons (cons (car buckets) ours)
              (bucket-group tail (cdr buckets))))))

(defun split-while (pred lst)
  (split-while* pred nil lst))

(defun split-while* (pred yes lst)
  (if (or (null lst)
          (not (funcall pred (car lst))))
      (list (nreverse yes) lst)
      (split-while* pred
                    (cons (car lst) yes)
                    (cdr lst))))

(split-while #'evenp '(2 4 6 5 7))
(split-while #'evenp '(2 4 6))
(split-while #'evenp '(5 6))

;; (ql:quickload "split-sequence")

(defun hash-partitions (parts))

(defun request (store partition-fn))

(defun sort-by-hlc (store))
