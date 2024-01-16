(defpackage crdt-lisp/tests/hlc
  (:use :cl
        :crdt-lisp/hlc
        :rove))
(in-package :crdt-lisp/tests/hlc)

(deftest send-recv-1
  (let* ((t0 (zero 'test-clock))
         (t1 (send t0 'test-clock)))

    (testing "init"
      (ok (= 1 (unix-milliseconds t0))))

    (testing "send"
      (ok (= 2 (unix-milliseconds t1))))

    (testing "recv-1"
      ;; physical time
      (ok (= 3 (unix-milliseconds (recv t1 (make-hlc :time 2 :tick 2) 'test-clock))))
      ;; message time
      (ok (= 4 (unix-milliseconds (recv t1 (make-hlc :time 4 :tick 2) 'test-clock))))
      ;; logical time
      (ok (= 2 (unix-milliseconds (recv t1 (make-hlc :time 1 :tick 2) 'zero-clock)))))))

(defun test-clock (last)
  (+ 1 last))

(defun zero-clock (last)
  (declare (ignore last))
  0)
