(defpackage crdt-lisp/tests/util
  (:use :cl
        :crdt-lisp/util
        :rove))
(in-package :crdt-lisp/tests/util)

(deftest utils-1
  (testing "split-while"
    (ok (equal (split-while #'evenp '(2 4 6 5 7))
               '((2 4 6) (5 7))))

    (ok (equal (split-while #'evenp '(2 4 6))
               '((2 4 6) NIL)))

    (ok (equal (split-while #'evenp '(5 6))
               '(NIL (5 6))))))
