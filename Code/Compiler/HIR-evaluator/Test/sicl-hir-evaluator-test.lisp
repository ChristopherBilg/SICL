(cl:in-package #:sicl-hir-evaluator-test)

(defparameter *client*
  (make-instance 'trucler-reference:client))

(defparameter *environment*
  (let ((sicl-boot:*e0* (make-instance 'sicl-boot-phase-0::environment
                          :name "HIR-evaluator-test-environment")))
    (sicl-boot-phase-0::host-load "Array/packages.lisp")
    (sicl-boot-phase-0::host-load "String/packages.lisp")
    (sicl-boot-phase-0:boot
     (make-instance 'sicl-boot:boot :e0 sicl-boot:*e0*))
    sicl-boot:*e0*))

;;; The test suite compares the behavior or EVAL on the host and the
;;; behavior of the evaluator.  To achieve that, the host needs to know how
;;; to handle primops.
(defparameter *primop-translations*
  '((cleavir-primop:car car)
    (cleavir-primop:cdr cdr)
    (cleavir-primop:rplaca rplaca)
    (cleavir-primop:rplacd rplacd)
    (cleavir-primop:eq eq)
    (cleavir-primop:multiple-value-call multiple-value-call)))

(defmacro with-primops (&body body)
  `(macrolet ,(loop for (primop translation) in *primop-translations*
                    collect
                    `(,primop (&rest args) `(,',translation ,@args)))
     ,@body))

;;; Define a few auxiliary functions and variables for testing.

(defun foo (x)
  (declare (ignore x))
  nil)

(setf (env:fdefinition
       *environment* (env:client *environment*) 'foo)
      #'foo)

(defun bar (x)
  (declare (ignore x))
  42)

(setf (env:fdefinition
        *environment* (env:client *environment*) 'bar)
      #'bar)

(defparameter *x* 5)

(setf (env:special-variable
        *environment* (env:client *environment*) '*x* t)
      *x*)
