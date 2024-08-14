(defpackage crdt-lisp
  (:use :cl))

(defpackage crdt-lisp/util
  (:use :cl :cl-arrows)
  (:import-from :cl-octet-streams)
  (:import-from :s-base64)
  (:export #:b64 #:unb64 #:split-while #:fn1))

(defpackage crdt-lisp/hlc
  (:import-from :cl-intbytes)
  (:local-nicknames (:u :crdt-lisp/util))
  (:use :cl :cl-arrows)
  (:export #:zero #:send #:recv
           #:make-hlc #:hlc-p #:hlc-time #:hlc-tick #:unix-ms
           #:lt? #:hulc-max
           #:hulc-string #:hulc-parse))

(defpackage crdt-lisp/node-id
  (:import-from :ironclad)
  (:import-from :local-time)
  (:local-nicknames (:h :crdt-lisp/hlc) (:u :crdt-lisp/util))
  (:use :cl :cl-arrows)
  (:export #:make-node-id #:epoch-node-id))

(defpackage crdt-lisp/schema
  (:import-from :crdt-lisp/hlc #:make-hlc #:hlc-p #:hlc-time #:hlc-tick #:unix-ms)
  (:use :cl)
  (:export #:messagep #:to-network #:to-lisp))

(defpackage crdt-lisp/anti-entropy
  (:import-from :fset #:$)
  (:import-from :ironclad)
  (:import-from :cl-octet-streams)
  (:local-nicknames (:h :crdt-lisp/hlc)
                    (:n :crdt-lisp/node-id))
  (:use :cl :cl-arrows :crdt-lisp/util)
  (:export #:make-store #:put #:fetch #:make-request))

(defpackage crdt-lisp/cluster/store
  (:import-from :crdt-lisp/node-id #:make-node-id)
  (:import-from :tsq)
  (:local-nicknames (:ae :crdt-lisp/anti-entropy)
                    (:h :crdt-lisp/hlc)
                    (:th :bordeaux-threads))
  (:use :cl :cl-arrows)
  (:export #:start-store! #:stop-store!
           #:send-time #:recv-time
           #:get-ae #:put-ae #:recv-ae
           #:make-ae-req #:make-ae-res #:recv-ae-res))

(defpackage crdt-lisp/cluster
  (:import-from :local-time)
  (:import-from :zmq)
  (:local-nicknames (:st :crdt-lisp/cluster/store)
                    (:th :bordeaux-threads))
  (:use :cl :cl-arrows)
  (:export #:join-cluster! #:send-cluster))

(defpackage crdt-lisp/main
  (:local-nicknames (:cluster :crdt-lisp/cluster)
                    (:st :crdt-lisp/cluster/store)
                    (:th :bordeaux-threads))
  (:use :cl :cl-arrows))

(in-package :crdt-lisp)

;; blah blah blah.
