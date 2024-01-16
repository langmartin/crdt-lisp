(defpackage crdt-lisp
  (:use :cl))

(defpackage crdt-lisp/hlc
  (:use :cl :local-time)
  (:export zero send recv unix-milliseconds make-hlc))

(in-package :crdt-lisp)

;; blah blah blah.
