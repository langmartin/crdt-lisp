(defpackage crdt-lisp
  (:use :cl))

(defpackage crdt-lisp/hlc
  (:use :cl :local-time :cl-arrows)
  (:export zero send recv unix-milliseconds make-hlc))

(defpackage crdt-lisp/cluster
  (:use :cl :local-time :crdt-lisp/hlc :cl-arrows)
  (:export join-cluster))

(defpackage crdt-lisp/node-id
  (:use :cl :cl-arrows :cl-octet-streams :s-base64 :cl-intbytes))

(defpackage crdt-lisp/schema
  (:use :cl)
  (:export messagep to-network to-lisp))

(in-package :crdt-lisp)

;; blah blah blah.
