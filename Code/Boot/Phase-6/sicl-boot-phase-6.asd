(cl:in-package #:asdf-user)

(defsystem #:sicl-boot-phase-6
  :depends-on (#:sicl-boot-base
               #:sicl-clos-boot-support)
  :serial t
  :components
  ((:file "packages")
   (:file "enable-typep")
   (:file "enable-object-creation")
   (:file "enable-array-access")
   (:file "enable-method-combinations")
   (:file "enable-defgeneric")
   (:file "enable-generic-function-creation")
   (:file "enable-defmethod")
   (:file "enable-defclass")
   (:file "create-cyclic-graph")
   (:file "prepare-this-phase")
   (:file "convert-functions")
   (:file "enable-deftype")
   (:file "enable-printing")
   (:file "enable-reading")
   (:file "enable-conditions")
   (:file "load-eclector")
   (:file "load-ctype")
   (:file "boot")))
