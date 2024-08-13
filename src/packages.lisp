(defpackage crdt-lisp
  (:use :cl))

(defpackage crdt-lisp/util
  (:use :cl :cl-arrows)
  (:import-from :cl-octet-streams)
  (:import-from :s-base64)
  (:export #:b64 #:unb64))

(defpackage crdt-lisp/hlc
  (:import-from :cl-intbytes)
  (:local-nicknames (:u :crdt-lisp/util))
  (:use :cl :cl-arrows)
  (:export #:zero #:send #:recv
           #:make-hlc #:hlc-p #:hlc-time #:hlc-tick #:unix-ms
           #:lt?
           #:hulc-string #:hulc-parse))

(defpackage crdt-lisp/cluster
  (:import-from :local-time)
  (:local-nicknames (:h :crdt-lisp/hlc))
  (:use :cl :cl-arrows)
  (:export #:join-cluster #:send-cluster))

(defpackage crdt-lisp/node-id
  (:import-from :ironclad)
  (:import-from :local-time)
  (:local-nicknames (:h :crdt-lisp/hlc) (:u :crdt-lisp/util))
  (:use :cl :cl-arrows)
  (:export #:make-node-id))

(defpackage crdt-lisp/schema
  (:import-from :crdt-lisp/hlc #:make-hlc #:hlc-p #:hlc-time #:hlc-tick #:unix-ms)
  (:use :cl)
  (:export #:messagep #:to-network #:to-lisp))

(defpackage crdt-lisp/anti-entropy
  (:import-from :fset #:$)
  (:import-from :ironclad)
  (:import-from :cl-octet-streams)
  (:local-nicknames (:h :crdt-lisp/hlc) (:u :crdt-lisp/util))
  (:use :cl :cl-arrows)
  (:export #:make-store #:put #:fetch))

(in-package :crdt-lisp)

;; blah blah blah.
