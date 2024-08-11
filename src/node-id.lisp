(in-package :crdt-lisp/node-id)

(defvar default-hostname (machine-instance))

(defun host-hash (&optional (hostname default-hostname))
  (with-output-to-string (out)
    (-> (->> hostname
             (sb-ext:string-to-octets)
             (ironclad:digest-sequence :crc32)
             (cl-octet-streams:make-octet-input-stream))
        (s-base64:encode-base64 out))))

;; (host-hash)
;; (cl-base64:usb8-array-to-base64-stream (host-hash))
;; (ql:quickload :s-base64)
;; (ql:quickload :cl-octet-streams)
