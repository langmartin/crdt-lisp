(defpackage crdt-lisp
  (:use :cl))

(defpackage crdt-lisp/util
  (:use :cl :cl-arrows)
  (:import-from :cl-octet-streams)
  (:import-from :s-base64)
  (:export b64 unb64))

(defpackage crdt-lisp/hlc
  (:use :cl :cl-arrows)
  (:import-from :cl-intbytes)
  (:local-nicknames (:u :crdt-lisp/util))
  (:export zero send recv make-hlc unix-ms lt? hulc-string hulc-parse))

(defpackage crdt-lisp/cluster
  (:use :cl :local-time :crdt-lisp/hlc :cl-arrows)
  (:export join-cluster send-cluster))

(defpackage crdt-lisp/node-id
  (:use :cl :cl-arrows)
  (:local-nicknames (:h :crdt-lisp/hlc) (:u :crdt-lisp/util))
  (:import-from :ironclad)
  (:import-from :local-time)
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
  (:import-from :ironclad)
  (:import-from :cl-octet-streams)
  (:local-nicknames (:h :crdt-lisp/hlc) (:u :crdt-lisp/util))
  (:use :cl :cl-arrows)
  (:export make-store put fetch))

(in-package :crdt-lisp)

;; blah blah blah.
