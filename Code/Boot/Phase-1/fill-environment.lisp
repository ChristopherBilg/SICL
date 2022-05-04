(cl:in-package #:sicl-boot-phase-1)

(defun define-function-global-environment (client environment)
  ;; This function is used by macros in order to find the current
  ;; global environment.  If no argument is given, the run-time
  ;; environment (or startup environment) is returned.  If a macro
  ;; supplies an argument, and then it will typically be the
  ;; environment given to it by the &ENVIRONMENT parameter, then
  ;; the compilation environment is returned.  Macros use this
  ;; function to find information that is truly global, and that
  ;; Trucler does not manage, such as compiler macros. type
  ;; definitions, SETF expanders, etc.
  (setf (env:fdefinition
         client
         environment
         ;; There has got to be an easier way to define the
         ;; package so that it exists before this system is
         ;; compiled.
         'env:global-environment)
        (lambda (&optional env)
          (if (null env)
              environment
              (trucler:global-environment client env)))))

(defun fill-environment (environment)
  (symbol-macrolet ((client sicl-client:*client*))
    (define-defmacro client environment)
    (define-backquote-macros client environment)
    (import-from-host environment)
    (when (null (find-package '#:sicl-sequence))
      (make-package '#:sicl-sequence :use '(#:common-lisp)))
    (define-defgeneric-expander client environment)
    (flet ((ld (relative-file-name)
             (load-source-file relative-file-name environment)))
      (host-load "Evaluation-and-compilation/packages.lisp")
      (host-load "Data-and-control-flow/packages.lisp")
      (host-load "Random/packages-intrinsic.lisp")
      (define-function-global-environment client environment)
      ;; Load a file containing a definition of the macro LAMBDA.
      ;; This macro is particularly simple, so it doesn't really
      ;; matter how it is expanded.  This is fortunate, because at the
      ;; time this file is loaded, the definition of DEFMACRO is still
      ;; one we created "manually" and which uses the host compiler to
      ;; compile the macro function in the null lexical environment.
      ;; We define the macro LAMBDA before we redefine DEFMACRO as a
      ;; target macro because PARSE-MACRO returns a LAMBDA form, so we
      ;; need this macro in order to redefine DEFMACRO.
      (ld "Evaluation-and-compilation/lambda.lisp")
      ;; Load a file containing the definition of the macro
      ;; MULTIPLE-VALUE-BIND.  We need it early because it is used in the
      ;; expansion of SETF, which we also need early for reasons explained
      ;; below.
      (ld "Data-and-control-flow/multiple-value-bind-defmacro.lisp")
      ;; Load a file containing definitions of standard conditional
      ;; macros, such as AND, OR, CASE, etc.
      (ld "Conditionals/macros.lisp")
      ;; Define a temporary version of SETF so that we can set the
      ;; MACRO-FUNCTION of the macros to be defined until we have a
      ;; proper version of DEFMACRO.  We need the SETF macro early,
      ;; because it is needed in order to define the macro DEFMACRO.
      ;; The reason for that, is that the expansion of DEFMACRO uses
      ;; SETF to set the macro function.  We could have defined
      ;; DEFMACRO to call (SETF MACRO-FUNCTION) directly, but that
      ;; would have been less "natural", so we do it this way instead.
      (setf (env:macro-function client environment 'setf)
            (lambda (form env)
              (declare (ignore env))
              (destructuring-bind (place value) (rest form)
                (check-type place (cons (eql macro-function)))
                `(funcall ,#'(setf env:macro-function)
                          ,value ,client ,environment ,(second place)))))
      ;; At this point, we have all the ingredients (the macros LAMBDA
      ;; and SETF) in order to redefine the macro DEFMACRO as a native
      ;; macro.  SINCE we already have a primitive form of DEFMACRO,
      ;; we use it to define DEFMACRO.  The result of loading this
      ;; file is that all new macros defined subsequently will have
      ;; their macro functions compiled with the target compiler.
      ;; However, the macro function of DEFMACRO is still compiled
      ;; with the host compiler.
      (ld "Evaluation-and-compilation/defmacro-defmacro.lisp")
      ;; As mentioned above, at this point, we have a version of
      ;; DEFMACRO that will compile the macro function of the macro
      ;; definition using the target compiler.  However, the macro
      ;; function of the macro DEFMACRO itself is still the result of
      ;; using the host compiler.  By loading the definition of
      ;; DEFMACRO again, we fix this "problem".
      (ld "Evaluation-and-compilation/defmacro-defmacro.lisp")
      ;; We might as well also define DEFINE-COMPILER-MACRO here.
      (ld "Evaluation-and-compilation/define-compiler-macro-defmacro.lisp")
      ;; We might as well also define DEFINE-SETF-EXPANDER here.
      (ld "Data-and-control-flow/define-setf-expander.lisp")
      ;; Up to this point, the macro function of the macro LAMBDA was
      ;; compiled using the host compiler.  Now that we have the final
      ;; version of the macro DEFMACRO, we can reload the file
      ;; containing the definition of the macro LAMBDA, which will
      ;; cause the macro function to be compiled with the target
      ;; compiler.
      (ld "Evaluation-and-compilation/lambda.lisp")
      ;; Similarly, the macro MULTIPLE-VALUE-BIND was compiled using
      ;; the host compiler.  By loading this file again, we will
      ;; compile the macro function again, this time with the target
      ;; compiler.
      (ld "Data-and-control-flow/multiple-value-bind-defmacro.lisp")
      ;; Similarly, the macros for conditional were compiled using the
      ;; host compiler.  By loading this file again, we will compile
      ;; those macro functions again, this time with the target
      ;; compiler.
      (ld "Conditionals/macros.lisp")
      ;; Load a file containing the definition of the macro
      ;; MULTIPLE-VALUE-LIST.  This definition is needed, because it
      ;; is used in the expansion of the macro NTH-VALUE loaded below.
      (ld "Data-and-control-flow/multiple-value-list-defmacro.lisp")
      (ld "Data-and-control-flow/nth-value.lisp")
      ;; We define MULTIPLE-VALUE-CALL as a macro.  This macro expands
      ;; to a primop that takes a function, rather than a function
      ;; designator, as its first argument.
      (ld "Data-and-control-flow/multiple-value-call-defmacro.lisp")
      (ld "Data-and-control-flow/setf-defmacro.lisp")
      (import-functions-from-host
       '(sicl-data-and-control-flow:defun-expander)
       environment)
      ;; Load a file containing the definition of macro DEFUN.
      (ld "Data-and-control-flow/defun-defmacro.lisp")
      (ld "Data-and-control-flow/defconstant-defmacro.lisp")
      (ld "Data-and-control-flow/defvar-defmacro.lisp")
      (ld "Data-and-control-flow/defparameter-defmacro.lisp")
      (ld "Symbol/symbol-value-etc-defuns.lisp")
      (ld "Evaluation-and-compilation/macroexpand-hook-defparameter.lisp")
      (ld "Evaluation-and-compilation/macroexpand-1-defun.lisp")
      (host-load "Evaluation-and-compilation/declaim-support.lisp")
      (import-functions-from-host
       '(sicl-evaluation-and-compilation:declaim-expander)
       environment)
      (ld "Evaluation-and-compilation/declaim-defmacro.lisp")
      ;; Load a file containing the definitions of the macros INCF and
      ;; DECF.
      (ld "Arithmetic/incf-decf-defmacro.lisp")
      (import-functions-from-host '(sicl-loop:expand-body) environment)
      (ld "Loop/loop-defmacro.lisp")
      ;; Load definitions of the macros PUSH and POP.
      (ld "Cons/push-pop-support.lisp")
      (ld "Cons/push-pop-defmacro.lisp")
      ;; Load a file containing the definition of the macro RETURN.
      (ld "Data-and-control-flow/return-defmacro.lisp")
      ;; Load a file containing the definitions of the macros PROG1
      ;; and PROG2.
      (ld "Data-and-control-flow/prog1-prog2-defmacro.lisp")
      ;; Load a file containing the definitions of the macros PROG and
      ;; PROG*.
      (import-functions-from-host
       '(cleavir-code-utilities:separate-ordinary-body)
       environment )
      (ld "Data-and-control-flow/prog-progstar-defmacro.lisp")
      (ld "Data-and-control-flow/psetf-support.lisp")
      (ld "Data-and-control-flow/psetf-defmacro.lisp")
      (ld "Data-and-control-flow/rotatef-support.lisp")
      (ld "Data-and-control-flow/rotatef-defmacro.lisp")
      (import-functions-from-host
       '(cleavir-code-utilities:parse-destructuring-bind)
       environment)
      (ld "Data-and-control-flow/destructuring-bind-defmacro.lisp")
      (ld "Data-and-control-flow/shiftf-support.lisp")
      (ld "Data-and-control-flow/shiftf-defmacro.lisp")
      ;; Define macro PUSHNEW.
      (ld "Cons/make-bindings-defun.lisp")
      (ld "Cons/pushnew-support.lisp")
      (ld "Cons/pushnew-defmacro.lisp")
      ;; Load a file containing the definition of the macro DOTIMES.
      (import-functions-from-host '(sicl-iteration:dotimes-expander) environment)
      (ld "Iteration/dotimes-defmacro.lisp")
      ;; Load a file containing the definition of the macro DOLIST.
      (import-functions-from-host '(sicl-iteration:dolist-expander) environment)
      (ld "Iteration/dolist-defmacro.lisp")
      ;; Load a file containing the definition of the macros DO and DO*.
      (import-functions-from-host '(sicl-iteration:do-dostar-expander) environment)
      (ld "Iteration/do-dostar-defmacro.lisp")
      ;; Define macro REMF.
      (ld "Cons/remf-support.lisp")
      (ld "Cons/remf-defmacro.lisp")
      ;; Load a file containing the definition of the macro
      ;; WITH-PROPER-LIST-RESTS used by the functions MEMBER,
      ;; MEMBER-IF, and MEMBER-IF-NOT.
      (ld "Cons/with-proper-list-rests-defmacro.lisp")
      ;; Load a file containing the definition of the macro
      ;; WITH-PROPER-LIST-ELEMENTS used by several functions such as
      ;; SET-DIFFERENCE, UNION, etc.
      (ld "Cons/with-proper-list-elements-defmacro.lisp")
      ;; Load a file containing the definition of the macro
      ;; WITH-ALIST-ELEMENTS used by functions in the ASSOC family.
      (ld "Cons/with-alist-elements-defmacro.lisp")
      (import-functions-from-host
       '(sicl-conditions:define-condition-expander)
       environment)
      (ld "Conditions/define-condition-defmacro.lisp")
      (ld "Conditions/assert-defmacro.lisp")
      (ld "Conditions/check-type-defmacro.lisp")
      (ld "Conditions/handler-bind-defmacro.lisp")
      (import-functions-from-host
       '(sicl-conditions:make-handler-case-without-no-error-case
         sicl-conditions:make-handler-case-with-no-error-case)
       environment)
      (ld "Conditions/handler-case-defmacro.lisp")
      (ld "Conditions/ignore-errors-defmacro.lisp")
      (import-functions-from-host
       '(sicl-conditions:restart-bind-transform-binding)
       environment)
      (ld "Conditions/restart-bind-defmacro.lisp")
      (import-functions-from-host
       '(sicl-conditions:restart-case-make-restart-binding
         sicl-conditions:restart-case-make-restart-case
         sicl-conditions:restart-case-signaling-form-p
         sicl-conditions:restart-case-expand-signaling-form
         sicl-conditions:restart-case-parse-case
         symbol-name
         cleavir-code-utilities:extract-named-group
         cleavir-code-utilities:extract-required
         cleavir-code-utilities:canonicalize-define-modify-macro-lambda-list
         cleavir-code-utilities:parse-deftype)
       environment)
      (ld "Conditions/restart-case-defmacro.lisp")
      (ld "Conditions/with-simple-restart-defmacro.lisp")
      (ld "Conditions/with-condition-restarts-defmacro.lisp")
      (import-functions-from-host '(sicl-clos:with-slots-expander) environment)
      (ld "CLOS/with-slots-defmacro.lisp")
      (import-functions-from-host '(sicl-clos:defclass-expander) environment)
      (ld "CLOS/defclass-defmacro.lisp")
      (ld "CLOS/defgeneric-defmacro.lisp")
      (import-functions-from-host
       '(sicl-clos:parse-defmethod
         sicl-clos::make-method-lambda-default
         sicl-clos:canonicalize-specializers)
       environment)
      (ld "Boot/Phase-1/defmethod-defmacro.lisp"))))
