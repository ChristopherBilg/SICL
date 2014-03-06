(cl:in-package #:common-lisp-user)

(asdf:defsystem :sicl-boot-phase1
  :depends-on (:sicl-code-utilities
	       :sicl-additional-conditions)
  :serial t
  :components
  ((:file "packages")
   (:file "rename-package-1")
   (:file "define-built-in-class")
   (:file "defclass")
   (:file "mop-class-hierarchy")
   (:file "bridge-generic-function")
   (:file "define-variables")
   (:file "class-database")
   (:file "ensure-class")
   (:file "ensure-built-in-class")
   (:file "classp")
   (:file "specializerp")
   (:file "generic-function-database")
   (:file "ensure-generic-function")
   (:file "ensure-method")
   (:file "reader-writer-method-class-support")
   (:file "reader-writer-method-class-defgenerics")
   (:file "reader-writer-method-class-defmethods")
   (:file "add-remove-direct-method-support")
   (:file "add-remove-direct-method-defuns")
   (:file "add-remove-method-support")
   (:file "add-remove-method-defuns")
   (:file "add-accessor-method")
   (:file "slot-definition-class-support")
   (:file "slot-definition-class-defuns")
   (:file "validate-superclass")
   (:file "class-initialization-support")
   (:file "class-initialization-defmethods")
   (:file "compute-applicable-methods-support")
   (:file "compute-applicable-methods-defgenerics")
   (:file "compute-applicable-methods-defmethods")
   (:file "compute-effective-method-support")
   (:file "compute-effective-method-support-a")
   (:file "method-combination-compute-effective-method-support")
   (:file "method-combination-compute-effective-method-defgenerics")
   (:file "method-combination-compute-effective-method-defmethods")
   (:file "compute-effective-method-defgenerics")
   (:file "compute-effective-method-defmethods")
   (:file "list-utilities")
   (:file "discriminating-automaton")
   (:file "discriminating-tagbody")
   (:file "heap-instance")
   (:file "class-of")
   (:file "standard-instance-access")
   (:file "compute-discriminating-function-support")
   (:file "compute-discriminating-function-support-a")
   (:file "compute-discriminating-function-defgenerics")
   (:file "compute-discriminating-function-defmethods")
   ;; Although we do not use the dependent maintenance facility, we
   ;; define the specified functions as ordinary functions that do
   ;; nothing, so that we can safely call them from other code.
   (:file "dependent-maintenance-support")
   (:file "dependent-maintenance-defuns")
   (:file "set-funcallable-instance-function")
   (:file "generic-function-initialization-support")
   (:file "generic-function-initialization-defmethods")
   (:file "direct-slot-definition-p")
   (:file "method-initialization-support")
   (:file "method-initialization-defmethods")
   (:file "print-object")
   (:file "class-finalization-defgenerics")
   (:file "class-finalization-support")
   (:file "class-finalization-defmethods")
   (:file "built-in-class-finalization")
   (:file "finalize-bridge-classes")
   (:file "allocate-instance-support")
   ;; We can not use the generic version of allocate instance, because
   ;; if we define a generic function here, it will be a host generic
   ;; function, and the generic version of allocate instance would
   ;; have to be a bridge generic function.
   (:file "allocate-instance-defuns")
   (:file "allocate-built-in-instance")
   (:file "slot-value-etc-support")
   (:file "slot-value-etc-defgenerics")
   (:file "slot-value-etc-defmethods")
   (:file "shared-initialize-support")
   (:file "initialize-built-in-instance-support")
   (:file "make-instance-support")
   (:file "make-built-in-instance-support")
   (:file "satiate-generic-functions")
   (:file "rename-package-2")))
