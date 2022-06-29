(cl:in-package #:sicl-boot-phase-6)

(defun load-ctype (e5)
  (load-source-file "Types/typexpand-defun.lisp" e5)
  (load-source-file "Arithmetic/type-definitions.lisp" e5)
  (sicl-boot:import-functions-from-host
   '(realp rationalp)
   e5)
  (load-source-file "Character/char-code-limit-defconstant.lisp" e5)
  (load-source-file "Cons/ldiff-defun.lisp" e5)
  (let ((*features* '(:sicl))) (ensure-asdf-system '#:ctype e5)))
