(defpackage crdt-lisp/tests/main
  (:use :cl
        :crdt-lisp
        :rove))
(in-package :crdt-lisp/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :crdt-lisp)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
