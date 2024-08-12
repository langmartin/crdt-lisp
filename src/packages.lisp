(defpackage crdt-lisp
  (:use :cl))

(defpackage crdt-lisp/hlc
  (:use :cl :cl-arrows)
  (:export zero send recv make-hlc unix-ms lt?))

(defpackage crdt-lisp/cluster
  (:use :cl :local-time :crdt-lisp/hlc :cl-arrows)
  (:export join-cluster))

(defpackage crdt-lisp/node-id
  (:use :cl :cl-arrows)
  (:export make-node-id))

(defpackage crdt-lisp/schema
  (:use :cl)
  (:export messagep to-network to-lisp))

(defpackage crdt-lisp/anti-entropy
  (:import-from :fset
                #:empty-map
                #:isetq
                #:lookup
                #:map-union
                #:$
                #:map-difference-2)
  (:local-nicknames (:h :crdt-lisp/hlc))
  (:use :cl :cl-arrows)
  (:export make-store put fetch))

(in-package :crdt-lisp)

;; blah blah blah.
