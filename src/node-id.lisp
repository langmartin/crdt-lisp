(in-package :crdt-lisp/node-id)

(defvar default-hostname (machine-instance))

(defun host-hash (&optional (hostname default-hostname))
  (->> hostname
       (sb-ext:string-to-octets)
       (ironclad:digest-sequence :crc32)))

(defun seconds (&optional (unix-seconds #'default-system-clock))
  (-> (funcall unix-seconds)
      (cl-intbytes:int32->octets)
      (reverse)))                       ; big endian for sorting, pls

(defun default-system-clock ()
  (-> (local-time:now)
      (local-time:timestamp-to-unix)))

(defun epoch-node-id ()
  (-> 0 cl-intbytes:int32->octets u:b64))

(defun make-node-id ()
  (u:b64
   (concatenate '(vector unsigned-byte)
                (host-hash)
                (seconds))))
