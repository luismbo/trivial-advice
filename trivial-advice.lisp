#-(or sbcl allegro)
(error "TRIVIAL-ADVICE has not yet been ported to this Lisp implementation.")

(defpackage :trivial-advice
  (:use :cl)
  (:export #:advise #:unadvise #:advisedp))

(in-package :trivial-advice)

(defun advise (function tag wrapper)
  #+allegro
  (let ((wrapper-name (gensym (format nil "WRAP-~a-~a" function tag))))
    (eval `(excl:def-fwrapper ,wrapper-name (&rest args)
	     (apply ,wrapper
		    (lambda (&rest new-args)
		      (setq excl:arglist new-args)
		      (excl:call-next-fwrapper))
		    args)))
    (excl:fwrap function tag wrapper-name))
  #+sbcl
  (progn
    (sb-int:unencapsulate function tag)
    (sb-int:encapsulate function tag wrapper)))

(defun unadvise (function tag)
  #+allegro (excl:funwrap function tag)
  #+sbcl (sb-int:unencapsulate function tag))

(defun advisedp (function tag)
  #+allegro (and (getf (excl:fwrap-order function) tag) t)
  #+sbcl (sb-int:encapsulated-p function tag))
