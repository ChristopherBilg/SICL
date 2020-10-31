(cl:in-package #:asdf-user)

(defsystem #:sicl-hir-evaluator-test
  :depends-on (#:sicl-boot-phase-0
               #:sicl-method-combination-support
               #:concrete-syntax-tree
               #:cleavir2-ast
               #:cleavir2-cst-to-ast
               #:cleavir2-primop
               #:sicl-hir-evaluator)
  :components
  ((:file "packages")
   (:file "sicl-hir-evaluator-test")
   (:file "tests")))
