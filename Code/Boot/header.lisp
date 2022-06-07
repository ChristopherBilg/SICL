(cl:in-package #:sicl-boot)

(defclass header (closer-mop:funcallable-standard-object)
  ((%class :initarg :class)
   (%rack :initarg :rack)
   ;; When a header instance is used to represent a function that is
   ;; executable as a host function, the following slot contains a
   ;; function that we might call the ORIGINAL FUNCTION.  The original
   ;; function is the argument passed to
   ;; SET-FUNCALLABLE-INSTANCE-FUNCTION to make this header instance
   ;; executable.  By keeping the original function around, we can
   ;; re-evaluate the call to SET-FUNCALLABLE-INSTANCE-FUNCTION later.
   ;; We use this possibility for things like tracing during
   ;; bootstrapping.  For that, we simply call
   ;; SET-FUNCALLABLE-INSTANCE-FUNCTION with a wrapper, wrapping the
   ;; original function in code that will display the trace message,
   ;; or do whatever we want done on function entry or exit.  Then,
   ;; undoing this wrapping is a simple matter of calling
   ;; SET-FUNCALLABLE-INSTANCE-FUNCTION, passing it the original
   ;; function.
   (%original-function
    :initform nil
    :initarg :original-function
    :accessor original-function))
  (:metaclass closer-mop:funcallable-standard-class))

;;; We define some subclasses of HEADER, mainly for debugging
;;; perposes.  We can then program Clouseau with methods specialized
;;; to these subclasses.  We use CHANGE-CLASS in later phases of
;;; bootstrapping to turn instances of HEADER into instances of
;;; subclasses of HEADER once we have a cyclic object graph in
;;; environment E5.

(defmacro define-header-class (name superclasses)
  `(defclass ,name ,superclasses ()
     (:metaclass closer-mop:funcallable-standard-class)))

(defclass function-header (header)
  ()
  (:metaclass closer-mop:funcallable-standard-class))

(defclass generic-function-header (function-header)
  ()
  (:metaclass closer-mop:funcallable-standard-class))

(defmethod sicl-ast-evaluator:translate-ast
    (client (ast cleavir-ast:nook-write-ast) lexical-environment)
  `(setf (aref (slot-value
                ,(sicl-ast-evaluator:translate-ast
                  client (cleavir-ast:object-ast ast) lexical-environment)
                '%rack)
               ,(sicl-ast-evaluator:translate-ast
                 client (cleavir-ast:nook-number-ast ast) lexical-environment))
         ,(sicl-ast-evaluator:translate-ast
           client (cleavir-ast:value-ast ast) lexical-environment)))

(defmethod sicl-ast-evaluator:translate-ast
    (client (ast cleavir-ast:nook-read-ast) lexical-environment)
  (let ((object-var (gensym))
        (nook-number-var (gensym)))
    `(let ((,nook-number-var
             ,(sicl-ast-evaluator:translate-ast
               client (cleavir-ast:nook-number-ast ast) lexical-environment))
           (,object-var
             ,(sicl-ast-evaluator:translate-ast
               client (cleavir-ast:object-ast ast) lexical-environment)))
       (if (zerop ,nook-number-var)
           ;; The stamp is asked for
           (flet ((unique-number (class-name)
                    (funcall (env:fdefinition
                              (env:client *e3*)
                              *e3*
                              'sicl-clos::unique-number)
                             (env:find-class (env:client *e4*) *e4* class-name))))
             (typecase ,object-var
                  (null (unique-number 'host-null))
                  (symbol (unique-number 'host-symbol))
                  (string (unique-number 'host-string))
                  (package (unique-number 'host-package))
                  (header
                   (aref (slot-value ,object-var '%rack) 0))
                  (t (error "Can't compute the stamp of ~s" ,object-var))))
           (aref (slot-value ,object-var '%rack) ,nook-number-var)))))

(defmethod sicl-hir-evaluator:instruction-thunk
    ((client client)
     (instruction cleavir-ir:nook-read-instruction)
     lexical-environment)
  (sicl-hir-evaluator:make-thunk
      (client instruction lexical-environment :inputs 2 :outputs 1)
    (setf (sicl-hir-evaluator:output 0)
          (if (zerop (sicl-hir-evaluator:input 1))
              ;; The stamp is asked for
              (flet ((unique-number (class-name)
                       (funcall (env:fdefinition
                                 client
                                  *e3*
                                 'sicl-clos::unique-number)
                                (env:find-class client *e4* class-name))))
                (typecase (sicl-hir-evaluator:input 0)
                  (null (unique-number 'host-null))
                  (symbol (unique-number 'host-symbol))
                  (string (unique-number 'host-string))
                  (package (unique-number 'host-package))
                  (header
                   (let ((rack (slot-value (sicl-hir-evaluator:input 0) '%rack)))
                     (aref rack 0)))
                  (t (error "Can't compute the stamp of ~s"
                            (sicl-hir-evaluator:input 0)))))
              (let ((rack (slot-value (sicl-hir-evaluator:input 0) '%rack)))
                (aref rack (sicl-hir-evaluator:input 1)))))
    (sicl-hir-evaluator:successor 0)))

(defmethod sicl-hir-evaluator:instruction-thunk
    ((client client)
     (instruction cleavir-ir:nook-write-instruction)
     lexical-environment)
  (sicl-hir-evaluator:make-thunk (client instruction lexical-environment :inputs 3)
    (setf (aref (slot-value (sicl-hir-evaluator:input 0) '%rack)
                (sicl-hir-evaluator:input 1))
          (sicl-hir-evaluator:input 2))
    (sicl-hir-evaluator:successor 0)))
