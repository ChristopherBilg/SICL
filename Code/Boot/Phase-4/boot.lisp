(cl:in-package #:sicl-boot-phase-4)

(defun boot (boot)
  (format *trace-output* "Start of phase 4~%")
  (with-accessors ((e3 sicl-boot:e3)
                   (e4 sicl-boot:e4)
                   (e5 sicl-boot:e5))
      boot
    (change-class e4 'environment)
    (import-from-host boot)
    (enable-class-finalization boot)
    (finalize-all-classes boot)
    (enable-defmethod boot)
    (enable-allocate-instance e3)
    (define-class-of e4)
    (enable-object-initialization boot)
    (load-fasl "Conditionals/macros.fasl" e3)
    (sicl-boot:enable-method-combinations #'load-fasl e3 e4)
    (define-stamp e4)
    (define-compile e4)
    (enable-generic-function-invocation boot)
    (sicl-boot:define-accessor-generic-functions #'load-fasl e3 e4 e5)
    (enable-class-initialization boot)
    (sicl-boot:create-mop-classes #'load-fasl e4)))
