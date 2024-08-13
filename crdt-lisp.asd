(defsystem "crdt-lisp"
  :version "0.1.0"
  :author ""
  :license ""
  :depends-on ("bordeaux-threads"
               "cl-arrows"
               "cl-intbytes"
               "cl-octet-streams"
               "fset"
               "ironclad"
               "local-time"
               "marshal"
               "s-base64"
               "tsqueue"
               "zeromq")
  :serial t
  :components ((:module "src"
                :components
                ((:file "packages")
                 (:file "util")
                 (:file "hlc")
                 (:file "schema")
                 (:file "node-id")
                 (:file "anti-entropy")
                 (:file "cluster/store")
                 (:file "cluster")
                 (:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "crdt-lisp/tests"))))

(defsystem "crdt-lisp/tests"
  :author ""
  :license ""
  :depends-on ("rove" "local-time")
  :components ((:module "tests"
                :components
                ((:file "hlc")
                 (:file "main")
                 (:file "anti-entropy"))))
  :description "Test system for crdt-lisp"
  :perform (test-op (op c) (symbol-call :rove :run c)))
