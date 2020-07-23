(fiasco:define-test-package :trivial-advice-tests
  (:use :cl :fiasco :trivial-advice))

(in-package :trivial-advice-tests)

(defun one-plus (x)
  (1+ x))

(deftest simple-advice ()
  (is (not (advisedp 'one-plus 'test)))
  (advise 'one-plus 'test
	  (lambda (fn &rest args)
	    (is (eql 42 (funcall fn 41)))
	    (cons 'advised (apply fn args))))
  (unwind-protect
       (progn
	 (is (advisedp 'one-plus 'test))
	 (is (equal '(advised . 1) (one-plus 0))))
    (unadvise 'one-plus 'test))
  (is (not (advisedp 'one-plus 'test)))
  (is (eql 2 (one-plus 1))))
