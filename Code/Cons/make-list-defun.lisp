(cl:in-package #:sicl-cons)

(defun make-list (length &key (initial-element nil))
  (unless (typep length '(integer 0))
    (error 'must-be-nonnegative-integer
           :datum length))
  (loop repeat length
        collect initial-element))
