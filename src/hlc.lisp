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

(defun unix-ms (hlc)
  (hlc-time hlc))

(defun lt? (a b)
  (or (< (hlc-time a) (hlc-time b))
      (and (= (hlc-time a) (hlc-time b))
           (< (hlc-tick a) (hlc-tick b)))))

(defun hulc-string (hlc node-id)
  (concatenate
   'string
   (u:b64
    (concatenate '(vector unsigned-byte)
                 (h->bs (hlc-time hlc) 6)
                 (h->bs (hlc-tick hlc) 2)))
   node-id))

(defun h->bs (int size)
  (-> int (cl-intbytes:int->octets size) (reverse)))

(defun bs->int (bytes start end)
  (let ((len (- end start)))
    (-> bytes (subseq start end) (reverse) (cl-intbytes:octets->uint len))))

(defun hulc-parse (hex-str-22)
  (let* ((hlc-pair (hulc-split hex-str-22))
         (node-id (cdr hlc-pair))
         (bytes (u:unb64 (car hlc-pair))))
    (cons (make-hlc :time (bs->int bytes 0 6)
                    :tick (bs->int bytes 6 8))
          node-id)))

(defun hulc-split (hex-str-22)
  (cons (subseq hex-str-22 0 11)
        (subseq hex-str-22 11 22)))

;;; Implement this interface to inject a clock for testing
(defun default-system-clock (_last)
  (declare (ignore _last))
  (let* ((lt (local-time:now))
         (s (local-time:timestamp-to-unix lt))
         (ms (local-time:timestamp-millisecond lt)))
    (+ (* 1000 s) ms)))

(let ((t0 (send (zero)))
      (n0 (crdt-lisp/node-id:make-node-id)))
  (length (u:unb64 (hulc-string t0 n0)))
  ;; (equalp (cons t0 n0)
  ;;         (hulc-parse (hulc-string t0 n0)))
  )
