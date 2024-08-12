(in-package :crdt-lisp/node-id)

(defvar default-hostname (machine-instance))

(defun host-hash (&optional (hostname default-hostname))
  (->> hostname
       (sb-ext:string-to-octets)
       (ironclad:digest-sequence :crc32)
       (base64)))

(defun base64 (octets)
  (->> (with-output-to-string (out)
         (-> octets
             (cl-octet-streams:make-octet-input-stream)
             (s-base64:encode-base64 out)))
       (string-right-trim "=")))

(defun seconds (&optional (unix-seconds #'default-system-clock))
  (-> (funcall unix-seconds)
      (cl-intbytes:int32->octets)
      (reverse)                         ; big endian for sorting, pls
      (base64)))

(defun default-system-clock ()
  (-> (local-time:now)
      (local-time:timestamp-to-unix)))

(defun make-node-id ()
  (concatenate 'string
               (host-hash)
               (seconds)))
