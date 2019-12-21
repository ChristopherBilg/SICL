(cl:in-package #:sicl-hir-to-mir)

(defun convert-one-function (client enter-instruction)
  (eliminate-enclose-instructions client enter-instruction)
  (let ((instructions '()))
    (cleavir-ir:map-local-instructions
     (lambda (instruction)
       (push instruction instructions))
     enter-instruction)
    (loop for instruction in instructions
          do (process-instruction client instruction))))

(defun hir-to-mir (client top-level-enter-instruction)
  (expand-funcall-instructions top-level-enter-instruction)
  (let ((enter-instructions
          (gather-enter-instructions top-level-enter-instruction)))
    (loop for enter-instruction in enter-instructions
          collect (convert-one-function client enter-instruction))
    top-level-enter-instruction))
