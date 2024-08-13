(defpackage crdt-lisp/tests/anti-entropy
  (:local-nicknames (:h :crdt-lisp/hlc)
                    (:u :crdt-lisp/util)
                    (:n :crdt-lisp/node-id)
                    (:sut :crdt-lisp/anti-entropy))
  (:use :cl
        :rove))

(in-package :crdt-lisp/tests/anti-entropy)

(deftest hashes-1
  (let* ((t0 (h:send (h:zero)))
         (n0 (n:make-node-id))
         (h0 (h:hulc-string t0 n0))
         (h1 (sut::hash-one "bar" h0))
         (h2 (sut::hash-one "foo" h0)))

    (testing "xor adds and is its own inverse"
      (= (sut::hash-xor h1 h2 h1)
         h2))

    (testing "encoding a hash to a string correctly"
      (= h2
         (sut::octets->int (u:unb64 (sut::hash-string h2)))))))
