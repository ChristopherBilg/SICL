(cl:in-package #:sicl-boot-phase-6)

(defun finalize-classes (e4 e5)
  (format *trace-output* "Finalizing all classes in ~a..." (sicl-boot:name e5))
  (finish-output *trace-output*)
  (let ((finalized-p (env:fdefinition (env:client e4) e4 'sicl-clos::class-finalized-p))
        (finalize (env:fdefinition (env:client e4) e4 'sicl-clos:finalize-inheritance)))
    (env:map-defined-classes
     (env:client e5) e5
     (lambda (name class)
       (declare (ignore name))
       (unless (funcall finalized-p class)
         (funcall finalize class)))))
  (format *trace-output* "done~%")
  (finish-output *trace-output*))

(defun satiate-generic-functions (e4 e5)
  (format *trace-output* "Satiating all generic functions in ~a..." (sicl-boot:name e5))
  (finish-output *trace-output*)
  (let ((satiation-function
          (env:fdefinition (env:client e4) e4 'sicl-clos::satiate-generic-function))
        (generic-function-class
          (env:find-class (env:client e4) e4 'standard-generic-function)))
    (env:map-defined-functions
     (env:client e5) e5
     (lambda (name function)
       (declare (ignore name))
       (when (and (typep function 'sicl-boot::header)
                  (eq (slot-value function 'sicl-boot::%class)
                      generic-function-class))
         (funcall satiation-function function)))))
  (format *trace-output* "done~%")
  (finish-output *trace-output*))

(defun prepare-this-phase (e3 e4 e5)
  (load-source-file "CLOS/class-of-defun.lisp" e5)
  (enable-typep e5)
  (load-source-file "Types/type-of-defgeneric.lisp" e5)
  (enable-object-creation e5)
  (setf (env:fdefinition (env:client e5) e5 'compile)
        (lambda (x lambda-expression)
          (assert (null x))
          (assert (and (consp lambda-expression) (eq (first lambda-expression) 'lambda)))
          (let* ((cst (cst:cst-from-expression lambda-expression))
                 (ast (cleavir-cst-to-ast:cst-to-ast (env:client e5) cst e5)))
            (with-intercepted-function-cells
                (e5
                 (make-instance
                  (env:function-cell (env:client e3) e3 'make-instance))
                 (sicl-clos:method-function
                  (env:function-cell (env:client e4) e4 'sicl-clos:method-function)))
              (sicl-boot:ast-eval (env:client e5) e5 ast)))))
  (enable-array-access e5)
  (enable-method-combinations e5)
  (enable-compute-discriminating-function e5)
  (enable-generic-function-creation e5)
  (enable-defmethod e5)
  (enable-defclass e5)
  ;; (enable-printing e5)
  (finalize-classes e4 e5)
  (load-source-file "CLOS/satiation.lisp" e4)
  (load-source-file "CLOS/standard-instance-access.lisp" e4)
  (satiate-generic-functions e4 e5)
  (update-all-objects e4 e5)
  ;; Now that we have a cyclic graph, we must change the reader
  ;; SICL-CLOS:ENVIRONMENT that we store in the CLIENT object, so that
  ;; it now refers to the function with that name in E5.
  (setf (sicl-boot-phase-5::static-environment-function (env:client e5))
        (env:fdefinition (env:client e5) e5 'sicl-clos:environment))
  (load-source-file "CLOS/ensure-generic-function-defun.lisp" e5)
  (load-source-file "CLOS/ensure-method-defun.lisp" e5)
  (load-source-file "CLOS/ensure-class.lisp" e5)
  (load-source-file "CLOS/satiation.lisp" e5)
  (satiate-generic-functions e5 e5)
  (setf (env:special-variable (env:client e5) e5 'sicl-clos::*class-unique-number* t)
        (nth-value 1 (env:special-variable (env:client e4) e4 'sicl-clos::*class-unique-number*))))
