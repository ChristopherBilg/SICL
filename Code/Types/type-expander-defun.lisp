(cl:in-package #:sicl-type)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function TYPE-EXPANDER.
;;;
;;; This function is defined the way it is because we want it to be
;;; defined in an environment where we will ultimately undefine
;;; functions with names in the SICL-ENVIRONMENT package.  So the
;;; function SICL-ENVIRONMENT:TYPE-EXPANDER and the CLIENT object of
;;; the environment are closed over at load time so that they can be
;;; undefined after this definition has been loaded.

(let* ((environment (env:global-environment))
       (client (env:client environment))
       (type-expander-function
         (env:fdefinition
          client environment 'env:type-expander)))
  (defun type-expander (type-descriptor)
    (funcall type-expander-function client environment type-descriptor)))
