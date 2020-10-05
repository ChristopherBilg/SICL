(cl:in-package #:common-lisp-user)

(defpackage #:sicl-hir-evaluator
  (:use #:common-lisp)
  (:local-nicknames (#:env #:sicl-environment))
  (:export #:cst-eval
           #:top-level-hir-to-host-function
           #:call-stack-entry
           #:origin
           #:arguments
           #:*call-stack*
           #:enclose
           #:initialize-closure
           #:symbol-value-function
           #:set-symbol-value-function
           #:fill-environment
           #:instruction-thunk
           #:make-thunk
           #:input
           #:output
           #:successor
           #:lexical-value
           #:input-value))
