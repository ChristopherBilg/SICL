(cl:in-package #:common-lisp-user)

(defpackage #:sicl-boot-phase-5
  (:use #:common-lisp)
  (:local-nicknames (#:env #:sicl-environment))
  (:import-from #:sicl-boot
                #:define-error-functions
                #:load-source-file
                #:import-functions-from-host
                #:with-intercepted-function-cells)
  (:export #:boot #:environment))
