(defpackage crdt-lisp/tests/anti-entropy
  (:local-nicknames (:h :crdt-lisp/hlc)
                    (:u :crdt-lisp/util)
                    (:n :crdt-lisp/node-id)
                    (:sut :crdt-lisp/anti-entropy))
  (:use :cl
        :rove
        :cl-arrows
        :crdt-lisp/anti-entropy))

(in-package :crdt-lisp/tests/anti-entropy)

(deftest hashes-1
  (let* ((t0 (h:send (h:zero)))
         (n0 (n:make-node-id))
         (h0 (h:hulc-string t0 n0))
         (h1 (sut::hash-one `("bar" . (,h0 . 3))))
         (h2 (sut::hash-one `("foo" . (,h0 . 3)))))

    (testing "xor adds and is its own inverse"
      (ok (= (sut::hash-xor (list h1 h2 h1))
             h2)))

    (testing "encoding a hash to a string correctly"
      (ok (= h2
             (sut::octets->int (u:unb64 (sut::hash-string h2))))))))

(deftest buckets-1
  (let ((store (-> (make-store)
                   (put "foo" "AZFRr4WvAACYa8I+ZrzYNA==" "bar")
                   (put "foo" "AZFRsJNSAACYa8I+ZrzYNA==" "baz")
                   (put "bar" "AZFRsReCAACYa8I+ZrzYNA==" "baz"))))
    (testing "sort"
      (ok (equal (sut::bucket-sort store)
                 '(("foo" "AZFRsJNSAACYa8I+ZrzYNA==" . "baz")
                   ("bar" "AZFRsReCAACYa8I+ZrzYNA==" . "baz")))))

    (testing "request"
      (ok (equal (make-request store (sut::hlc-buckets 54 10 3))
                 '(("AAAAAAAyAAAAAAAA" . "jVjnptKI6UNE+yrhXQmpe10JBcdd0cl+l+OSCjIoU5g=")
                   ("AAAAAAAoAAAAAAAA" . "")
                   ("AAAAAAAAAAAAAAAA" . "")))))))
