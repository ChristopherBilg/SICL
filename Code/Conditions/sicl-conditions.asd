(cl:in-package #:asdf-user)

(defsystem :sicl-conditions
  :serial t
  :components
  ((:file "packages")
   (:file "report-mixin-defclass")
   (:file "support")
   (:file "debugger-hook-defparameter")
   (:file "break-on-signals-defparameter")
   (:file "condition-defclass")
   (:file "debugger")
   (:file "define-condition-support")
   (:file "define-condition-defmacro")
   (:file "condition-hierarchy")
   (:file "with-store-value-restart-defmacro")
   (:file "check-type-defmacro")
   (:file "restart-defclass")
   (:file "restarts-utilities")
   (:file "restart-clusters-defvar")
   (:file "restarts")
   (:file "handlers-utilities")
   (:file "handlers")
   (:file "make-condition-defgeneric")
   (:file "make-condition-defmethods")
   (:file "coerce-to-condition")
   (:file "break-defun")
   (:file "handler-clusters-defvar")
   (:file "signaling")
   (:file "assert-defmacro")))
