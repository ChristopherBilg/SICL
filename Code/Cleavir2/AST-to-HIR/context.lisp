(cl:in-package #:cleavir-ast-to-hir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compilation context.
;;;
;;; Each AST is compiled in a particular COMPILATION CONTEXT or
;;; CONTEXT for short.  A context object has five components:
;;;
;;; 1. SUCCESSORS, which is a proper list containing one or two
;;; elements.  These elements are instructions resulting from the
;;; generation of the code that should be executed AFTER the code
;;; generated from this AST.  If the list contains two elements, then
;;; this AST is compiled in a context where a Boolean result is
;;; required.  In this case, the first element of the list is the
;;; successor to use when the value generated by the AST is NIL, and
;;; the second element is the successor to use when the value
;;; generated by the AST is something other than NIL.
;;;
;;; 2. RESULTS, indicating how many values are required from the
;;; compilation of this AST.  It can be either a list or an atom as
;;; describe below.  If it is a list, it contains zero or more lexical
;;; locations into which the generated code must put the values of
;;; this AST.  If the list contains more elements than the number of
;;; values generated by this AST, then the remaining lexical locations
;;; in the list must be filled with NIL by the code generated from
;;; this AST.  If it is an atom then it is a single datum of the type
;;; VALUES-LOCATION, which means that ALL values are required and
;;; should be stored in that location.
;;;
;;; 3. INVOCATION, always an ENTER-INSTRUCTION.  It indicates the
;;; function to which the code to be compiled belongs.
;;;
;;; 4. DYNAMIC-ENVIRONMENT-LOCATION, which is a lexical location that
;;; indicates in which dynamic environment an instruction is executed.
;;; The value of this component is stored in the corresponding slot in
;;; each instruction.
;;;
;;; The following combinations of SUCCESSORS and RESULTS can occur:
;;;
;;;   SUCCESSORS has one element.  then RESULTS can be a list of
;;;   lexical locations or the keyword symbol :VALUES.
;;;
;;;      If RESULTS is the empty list, this means that no values are
;;;      required.  Forms inside a PROGN other than the last are
;;;      compiled in a context like this.
;;;
;;;      If RESULTS is a singleton list, then a single value is
;;;      required.  Arguments to function calls are examples of ASTs
;;;      that are compiled in a context like this.
;;;
;;;      If RESULTS is a list with more than one element, then that
;;;      many values are required.  The VALUES-FORM-AST of
;;;      MULTIPLE-VALUE-BIND-AST is compiled in a context like this.
;;;
;;;      If RESULTS is the symbol :VALUES, then all values are
;;;      required and will be stored in the global values location.
;;;
;;;   SUCCESSOR has two elements.  Then RESULTS is the empty list,
;;;   meaning that no values are required.  The TEST-AST of an IF-AST
;;;   is compiled in a context like this.
;;;
;;;   SUCCESSORS has more than two elements.  This possibility is
;;;   currently not used.  It is meant to be used for forms like CASE,
;;;   TYPECASE, etc.  Again, the RESULTS would be the empty list.
;;;   Notice that We do have instructions with more than two
;;;   successors.  The CATCH-INSTRUCTION is such an instruction.  But
;;;   those successors are not generated as a result of the SUCCESSORS
;;;   information in the compilation context.

(defclass context ()
  ((%results :initarg :results :reader results)
   (%successors :initarg :successors :accessor successors)
   (%invocation :initarg :invocation :reader invocation)
   (%dynamic-environment-location
    :initarg :dynamic-environment-location
    :reader dynamic-environment-location)))

(defmethod initialize-instance :after ((context context) &key result successor)
  (let ((successors (if (null successor) (successors context) (list successor)))
        (results (if (null result) (results context) (list result))))
    (unless (or (and (listp results)
                     (every (lambda (result)
                              (typep result 'cleavir-ir:lexical-location))
                            results))
                (eq results :values))
      (error "illegal results: ~s" results))
    (unless (and (listp successors)
                 (<= 1 (length successors) 2)
                 (every (lambda (successor)
                          (typep successor 'cleavir-ir:instruction))
                        successors))
      (error "illegal successors: ~s" successors))
    (when (and (= (length successors) 2) (not (null results)))
      (error "Illegal combination of results and successors"))
    (unless (typep (invocation context) 'cleavir-ir:enter-instruction)
      (error "Illegal invocation"))
    (unless (typep (dynamic-environment-location context) 'cleavir-ir:lexical-location)
      (error "Illegal dynamic environment location ~s"
             (dynamic-environment-location context)))
    (reinitialize-instance context
      :results results
      :successors successors)))

(defun context
    (results
     successors
     invocation
     dynamic-environment-location)
  (make-instance 'context
    :results results
    :successors successors
    :invocation invocation
    :dynamic-environment-location dynamic-environment-location))

(defmethod print-object ((obj context) stream)
  (print-unreadable-object (obj stream :type t)
    (format stream "results: ~s" (results obj))
    (format stream " successors: ~s" (successors obj))
    (format stream " dynenv: ~s" (dynamic-environment-location obj))))

(defun clone-context (context &rest keyword-arguments)
  (apply #'make-instance 'context
         (append
          keyword-arguments
          (list :results (results context)
                :successors (successors context)
                :invocation (invocation context)
                :dynamic-environment-location
                (dynamic-environment-location context)))))
