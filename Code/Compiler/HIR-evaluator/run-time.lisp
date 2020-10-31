(cl:in-package #:sicl-hir-evaluator)

(defclass hir-closure (closer-mop:funcallable-standard-object)
  ((%environment :initarg :environment :reader environment))
  (:metaclass closer-mop:funcallable-standard-class))

(defun enclose (entry-point code-object static-environment-length lexical-locations)
  (let* ((static-environment
           (make-array (+ sicl-compiler:+first-constant-index+ static-environment-length)))
         (closure (make-instance 'hir-closure
                    :environment static-environment)))
    (setf (svref static-environment sicl-compiler:+code-object-index+)
          code-object)
    (setf (svref static-environment sicl-compiler:+enclose-function-index+)
          #'enclose)
    (setf (svref static-environment sicl-compiler:+initialize-closure-function-index+)
          #'initialize-closure)
    (setf (svref static-environment sicl-compiler:+cons-function-index+)
          #'cons)
    (setf (svref static-environment sicl-compiler:+nil-index+)
          nil)
    (closer-mop:set-funcallable-instance-function
     closure
     (lambda (&rest args)
       (funcall entry-point
                args
                static-environment
                sicl-run-time:*dynamic-environment*
                lexical-locations)))
    closure))

(defun initialize-closure (closure &rest static-environment-values)
  (check-type closure hir-closure)
  (let ((static-environment (environment closure)))
    (declare (simple-vector static-environment))
    (replace static-environment static-environment-values
             :start1 sicl-compiler:+first-constant-index+)))

(defun symbol-value-function (global-environment)
  (lambda (symbol)
    (loop with client = (env:client global-environment)
          for entry in sicl-run-time:*dynamic-environment*
          when (and (typep entry 'sicl-run-time:special-variable-entry)
                    (eq (sicl-run-time:name entry) symbol))
            return (sicl-run-time:value entry)
          finally
             (multiple-value-bind (value boundp)
                 (env:special-variable client global-environment symbol)
               (if boundp
                   (return value)
                   (multiple-value-bind (value boundp)
                       (env:constant-variable client global-environment symbol)
                     (if boundp
                         (return value)
                         (error "Unbound variable ~s" symbol))))))))

(defun set-symbol-value-function (global-environment)
  (lambda (value symbol)
    (loop with client = (env:client global-environment)
          for entry in sicl-run-time:*dynamic-environment*
          when (and (typep entry 'sicl-run-time:special-variable-entry)
                    (eq (sicl-run-time:name entry) symbol))
            do (setf (sicl-run-time:value entry) value)
               (return-from set-symbol-value-function value)
          finally
             ;; FIXME, make sure it is special.
             (setf (env:special-variable client global-environment symbol t)
                   value)
             (return value))))

(defun fill-environment (environment)
  (let ((client (env:client environment)))
    (setf (env:fdefinition client environment 'enclose)
          #'enclose)
    (setf (env:fdefinition client environment 'initialize-closure)
          #'initialize-closure)
    (setf (env:fdefinition client environment 'symbol-value)
          (symbol-value-function environment))
    (setf (env:fdefinition client environment '(setf symbol-value))
          (set-symbol-value-function environment))))
