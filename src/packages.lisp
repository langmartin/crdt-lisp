(defpackage crdt-lisp
  (:use :cl))

(defpackage crdt-lisp/hlc
  (:use :cl :local-time)
  (:export zero send recv unix-milliseconds make-hlc))

(defpackage crdt-lisp/cluster
  (:use :cl :local-time :crdt-lisp/hlc :cl-arrows)
  (:export join-cluster))

(defpackage crdt-lisp/schema
  (:use :cl)
  (:export messagep to-network to-lisp))

(in-package :crdt-lisp)

;; blah blah blah.
