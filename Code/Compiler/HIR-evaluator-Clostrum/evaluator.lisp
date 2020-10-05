(in-package #:sicl-hir-evaluator)

;; A list of call stack entries.
(defparameter *call-stack* '())

(defclass call-stack-entry ()
  ((%origin :initarg :origin :reader origin)
   (%arguments :initarg :arguments :reader arguments)))

;; A list of all values returned by the last function call.
(defvar *global-values-location* nil)

;; A hash table, caching the thunk of each instruction that has already
;; been converted.
(defvar *instruction-thunks*)

;; The main entry point for converting instructions to thunks.
(defgeneric instruction-thunk (client instruction lexical-environment))

(defmethod instruction-thunk :around
    (client instruction lexical-environment)
  (multiple-value-bind (thunk presentp)
      (gethash instruction *instruction-thunks*)
    (if presentp thunk (call-next-method))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Representing HIR as host functions.

(defun hir-to-host-function (client enter-instruction lexical-environment)
  (let* ((lexical-environment
           (make-lexical-environment :parent lexical-environment))
         (static-environment-lref-1
           (ensure-lref 'static-environment lexical-environment))
         (static-environment-lref-2
           (ensure-lref (cleavir-ir:static-environment enter-instruction) lexical-environment))
         (dynamic-environment-lref-1
           (ensure-lref 'dynamic-environment lexical-environment))
         (dynamic-environment-lref-2
           (ensure-lref (cleavir-ir:dynamic-environment-output enter-instruction) lexical-environment))
         (arguments-lref
           (ensure-lref 'arguments lexical-environment))
         (successor
           (first (cleavir-ir:successors enter-instruction)))
         (thunk
           (instruction-thunk client successor lexical-environment)))
    (lambda (arguments static-environment dynamic-environment lexical-locations)
      (let ((lexical-locations (lexical-environment-vector lexical-environment lexical-locations))
            (thunk thunk))
        (macrolet ((lref (lref)
                     `(%lref lexical-locations ,lref)))
          (setf (lref static-environment-lref-1) static-environment)
          (setf (lref static-environment-lref-2) static-environment)
          (setf (lref dynamic-environment-lref-1) dynamic-environment)
          (setf (lref dynamic-environment-lref-2) dynamic-environment)
          (setf (lref arguments-lref) (coerce arguments 'vector)))
        (catch 'return
          (loop (setf thunk (funcall thunk lexical-locations))))))))

(defun top-level-hir-to-host-function (client enter-instruction)
  (let* ((*instruction-thunks* (make-hash-table :test #'eq))
         (lexical-environment (make-lexical-environment))
         (static-environment-lref-1
           (ensure-lref 'static-environment lexical-environment))
         (static-environment-lref-2
           (ensure-lref (cleavir-ir:static-environment enter-instruction) lexical-environment))
         (dynamic-environment-lref-1
           (ensure-lref 'dynamic-environment lexical-environment))
         (dynamic-environment-lref-2
           (ensure-lref (cleavir-ir:dynamic-environment-output enter-instruction) lexical-environment))
         (successor
           (first (cleavir-ir:successors enter-instruction)))
         (thunk
           (instruction-thunk client successor lexical-environment)))
    (lambda (static-environment)
      (let ((lexical-locations (lexical-environment-vector lexical-environment nil))
            (thunk thunk))
        (macrolet ((lref (lref)
                     `(%lref lexical-locations ,lref)))
          (setf (lref static-environment-lref-1) static-environment)
          (setf (lref static-environment-lref-2) static-environment)
          (setf (lref dynamic-environment-lref-1) '())
          (setf (lref dynamic-environment-lref-2) '()))
        (catch 'return
          (loop (setf thunk (funcall thunk lexical-locations))))))))
