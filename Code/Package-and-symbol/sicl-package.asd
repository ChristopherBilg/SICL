(cl:in-package #:asdf-user)

(defsystem #:sicl-package
  :serial t
  :description "SICL-Specific Package System"
  :depends-on (#:acclimation #:cleavir-code-utilities)
  :components ((:file "packages")
               (:file "package-defclass")
               (:file "package-designator-deftype")
               (:file "package-name-defun")
               (:file "package-use-list-defun")
               (:file "package-used-by-list-defun")
               (:file "package-shadowing-symbols-defun")
               (:file "package-defparameter")
               (:file "utilities")
               (:file "resolve-conflict")
               (:file "export-defun")
               (:file "unexport-defun")
               (:file "import-defun")
               (:file "intern-defun")
               (:file "unintern-defun")
               (:file "shadow-defun")
               (:file "shadowing-import-defun")
               (:file "use-package-defun")
               (:file "do-symbols-defmacro")
               (:file "do-external-symbols-defmacro")
               (:file "make-package-defun")
               (:file "defpackage-defmacro")
	       (:file "conditions")
	       (:file "condition-reporters-english")
	       (:file "documentation-strings-english")))
