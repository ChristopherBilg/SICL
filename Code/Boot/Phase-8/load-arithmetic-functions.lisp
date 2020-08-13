(cl:in-package #:sicl-boot-phase-8)

(defun load-arithmetic-functions (e5)
  (load-source "Arithmetic/less-defun.lisp" e5)
  (load-source "Arithmetic/less-or-equal-defun.lisp" e5)
  (load-source "Arithmetic/greater-defun.lisp" e5)
  (load-source "Arithmetic/greater-or-equal-defun.lisp" e5)
  (load-source "Arithmetic/equal-defun.lisp" e5)
  (load-source "Arithmetic/not-equal-defun.lisp" e5)
  (load-source "Arithmetic/plusp-defun.lisp" e5)
  (load-source "Arithmetic/minusp-defun.lisp" e5)
  (load-source "Arithmetic/minus-defun.lisp" e5)
  (load-source "Arithmetic/one-plus-defun.lisp" e5)
  (load-source "Arithmetic/one-minus-defun.lisp" e5)
  (load-source "Arithmetic/min-defun.lisp" e5)
  (load-source "Arithmetic/max-defun.lisp" e5)
  (load-source "Arithmetic/zerop-defun.lisp" e5)
  (load-source "Arithmetic/integerp-defun.lisp" e5)
  (import-function-from-host 'sicl-genv:type-expander e5)
  (load-source "Arithmetic/binary-logior-defgeneric.lisp" e5)
  (load-source "Arithmetic/binary-logior-defmethods.lisp" e5)
  (load-source "Arithmetic/logior-defun.lisp" e5)
  (load-source "Arithmetic/binary-logxor-defgeneric.lisp" e5)
  (load-source "Arithmetic/binary-logxor-defmethods.lisp" e5)
  (load-source "Arithmetic/logxor-defun.lisp" e5)
  (load-source "Arithmetic/binary-logand-defgeneric.lisp" e5)
  (load-source "Arithmetic/binary-logand-defmethods.lisp" e5)
  (load-source "Arithmetic/logand-defun.lisp" e5)
  (load-source "Arithmetic/lognot-defun.lisp" e5)
  (load-source "Arithmetic/lognand-defun.lisp" e5)
  (load-source "Arithmetic/lognor-defun.lisp" e5)
  (load-source "Arithmetic/logandc1-defun.lisp" e5)
  (load-source "Arithmetic/logandc2-defun.lisp" e5)
  (load-source "Arithmetic/numberp-defgeneric.lisp" e5)
  (load-source "Arithmetic/realp-defgeneric.lisp" e5)
  (load-source "Arithmetic/allocate-instance-defmethod-bignum.lisp" e5)
  (load-source "Arithmetic/initialize-instance-defmethod-after-bignum.lisp" e5))
