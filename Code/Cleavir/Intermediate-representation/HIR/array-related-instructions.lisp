(cl:in-package #:cleavir-ir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction AREF-INSTRUCTION.
;;;
;;; Reads a value from an array.
;;; This instruction takes two inputs: an array and an index.
;;; The array must have the actual element-type of the instruction,
;;; and have actual simplicity corresponding to simple-p.
;;; The index is row-major.
;;; There is a single output, the read value.

(defclass aref-instruction (instruction one-successor-mixin)
  ((%element-type :initarg :element-type :reader element-type)
   (%simple-p :initarg :simple-p :reader simple-p)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction ASET-INSTRUCTION.
;;;
;;; Writes an object into an array.
;;; Three inputs: an array, an index, and an object.
;;; The array is under the same restrictions as above and the index
;;; is row-major. The object must be of the instruction element-type.
;;; No outputs.

(defclass aset-instruction
    (instruction one-successor-mixin side-effect-mixin)
  ((%element-type :initarg :element-type :reader element-type)
   (%simple-p :initarg :simple-p :reader simple-p)))
