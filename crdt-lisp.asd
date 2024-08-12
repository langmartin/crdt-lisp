(defsystem "crdt-lisp"
  :version "0.1.0"
  :author ""
  :license ""
  :depends-on ("cl-arrows"
               "cl-intbytes"
               "cl-octet-streams"
               "fset"
               "ironclad"
               "local-time"
               "s-base64"
               "zeromq")
  :serial t
  :components ((:module "src"
                :components
                ((:file "packages")
                 (:file "hlc")
                 (:file "cluster")
                 (:file "schema")
                 (:file "node-id")
                 (:file "anti-entropy"))))
  :description ""
  :in-order-to ((test-op (test-op "crdt-lisp/tests"))))

(defsystem "crdt-lisp/tests"
  :author ""
  :license ""
  :depends-on ("rove" "local-time")
  :components ((:module "tests"
                :components
                ((:file "hlc")
                 (:file "main"))))
  :description "Test system for crdt-lisp"
  :perform (test-op (op c) (symbol-call :rove :run c)))
