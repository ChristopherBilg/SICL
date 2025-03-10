(cl:in-package #:sicl-cons)

(defun get-properties (plist indicator-list)
  (unless (typep plist 'list)
    (error 'must-be-property-list
           :datum plist))
  (loop for rest on plist by #'cddr
        do (unless (consp (cdr rest))
             (error 'must-be-property-list
                    :datum plist))
           (let ((temp (member (car rest) indicator-list :test #'eq)))
             (unless (null temp)
               (return-from get-properties (values (car temp) (cadr rest) rest))))
        finally (unless (null rest)
                  (error 'must-be-property-list
                         :datum plist))
                (return (values nil nil nil))))
