(defsystem "crdt-lisp"
  :version "0.1.0"
  :author ""
  :license ""
  :depends-on ("cl-arrows")
  :components
  ((:module "src"
    :components
    ((:file "packages")
     (:module "hlc"
      :depends-on ("local-time")
      :components
      ((:file "hlc")))
     (module "cluster"
             :depends-on ("zeromq")
             :components
             ((:file "cluster")))
     (:file "schema")
     (module "node-id"
             :depends-on ("cl-intbytes" "cl-octet-streams" "ironclad" "s-base64")
             :components
             ((:file "node-id"))))))
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
