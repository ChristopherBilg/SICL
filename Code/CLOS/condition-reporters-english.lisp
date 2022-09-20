(cl:in-package #:sicl-clos)

(defmethod acclimation:report-condition
    ((c readers-must-be-proper-list)
     stream
     (language acclimation:english))
  (format stream
          "The keyword argument :READERS when supplied as~@
           initialization of a slot definition, must be~@
           a proper list, but the following was found instead:~@
           ~s."
          (readers c)))

(defmethod acclimation:report-condition
    ((c malformed-documentation-option)
     stream
     (language acclimation:english))
  (format stream
          "A documentation option must have the form~@
           (:documentation <name>), but~@
           ~s was found."
          (type-error-datum c)))

(defmethod acclimation:report-condition
    ((c attempt-to-access-precedence-list-of-unfinalized-class)
     stream
     (language acclimation:english))
  (format stream
          "Attempt to access the precedence list of the class ~s~@
          which has not yet been finalized."
          (offending-class c)))

(defmethod acclimation:report-condition
    ((c no-such-class-name)
     stream
     (language acclimation:english))
  (format stream
          "There is no class with the name ~s."
          (type-error-datum c)))

(defmethod acclimation:report-condition
    ((c slot-definition-argument-must-be-supplied)
     stream
     (language acclimation:english))
  (format stream "The slot-definition argument must be supplied."))

(defmethod acclimation:report-condition
    ((c unable-to-compute-class-precedence-list)
     stream
     (language acclimation:english))
  (format stream
          "Unable to compute the class precedence list of the class ~s"
          (offending-class c)))

(defmethod acclimation:report-condition
    ((c option-or-method-must-be-non-empty-list)
     stream
     (language acclimation:english))
  (format stream
          "Option or method must be a non-empty list,~@
           but the following expression was found instead~@
           ~s"
          (expression c)))
