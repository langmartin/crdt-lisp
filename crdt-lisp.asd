(defsystem "crdt-lisp"
  :version "0.1.0"
  :author ""
  :license ""
  :depends-on ("local-time"
               "cl-arrows")
  :components ((:module "src"
                :components
                ((:file "packages")
                 (:file "hlc")
                 (:file "cluster")
                 (:file "schema"))))
  :description ""
  :in-order-to ((test-op (test-op "crdt-lisp/tests"))))

(defsystem "crdt-lisp/tests"
  :author ""
  :license ""
  :depends-on ("crdt-lisp"
               "rove"
               "local-time")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for crdt-lisp"
  :perform (test-op (op c) (symbol-call :rove :run c)))
