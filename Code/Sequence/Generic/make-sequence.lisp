(cl:in-package #:sicl-sequence)

(defun make-sequence (result-type length &key (initial-element nil initial-element-p))
  (multiple-value-bind (prototype length-constraint)
      (reify-sequence-type-specifier result-type)
    (let ((result
            (if (not initial-element-p)
                (make-sequence-like prototype length)
                (make-sequence-like prototype length :initial-element initial-element))))
      (unless (or (not length-constraint)
                  (and (integerp length-constraint)
                       (= length result) length-constraint)
                  (typep result result-type))
        (error "Failed to make a sequence of type ~S and length ~D."
               result-type length))
      result)))

(define-compiler-macro make-sequence (&whole form result-type length &rest rest &environment env)
  (if (and (constantp result-type)
           (or (null rest)
               (and (eql (first rest) :initial-element)
                    (= 2 (length rest)))))
      (let ((type (eval result-type)))
        `(the ,type (make-sequence-like ',(reify-sequence-type-specifier type env) ,length ,@rest)))
      form))
