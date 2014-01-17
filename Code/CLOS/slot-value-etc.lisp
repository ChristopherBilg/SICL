(in-package #:sicl-clos)

(defun find-slot (object slot-name)
  (let* ((class (class-of object))
	 (slots (if (eq class *standard-class*)
		    (standard-instance-access
		     object *standard-class-class-slots-location*)
		    (class-slots class)))
	 (name-test (lambda (slot-definition)
		      (if (eq (class-of slot-definition)
			      *standard-effective-slot-definition*)
			  (standard-instance-access
			   object
			   *standard-effective-slot-definition-name-location*)
			  (slot-definition-name slot-definition)))))
    (find slot-name slots :test #'eq :key name-test)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; SLOT-EXISTS-P.

(defun slot-exists-p (object slot-name)
  (not (null (find-slot object slot-name))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; SLOT-MISSING.

(defgeneric slot-missing
    (class object slot-name operation &optional new-value))

(defmethod slot-missing
    (class object slot-name operation &optional new-value)
  (error "the slot named ~s is missing from the object ~s"
	 slot-name object))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; SLOT-UNBOUND.

(defgeneric slot-unbound (class object slot-name))

(defmethod slot-unbound (class object slot-name)
  (error "the slot named ~s is unbound in the object ~s"
	 slot-name object))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; SLOT-VALUE, (SETF SLOT-VALUE), 
;;; SLOT-VALUE-USING-CLASS (SETF SLOT-VALUE-USING-CLASS)

(defgeneric slot-value-using-class (class object slot))

(defun slot-value-using-class-aux (class object slot)
  (let* ((location (slot-definition-location slot))
	 (value 
	   (if (consp location)
	       (car location)
	       (slot-contents (heap-instance-slots object)
			      location))))
    (if (eq value *unbound-value*)
	(slot-unbound class object (slot-definition-name slot))
	value)))

(defmethod slot-value-using-class ((class standard-class)
				   object
				   (slot standard-effective-slot-definition))
  (slot-value-using-class-aux class object slot))

(defmethod slot-value-using-class ((class funcallable-standard-class)
				   object
				   (slot standard-effective-slot-definition))
  (slot-value-using-class-aux class object slot))

(defmethod slot-value-using-class ((class built-in-class)
				   object
				   slot)
  (declare (ignore object))
  (error "no slots in an instance of a builtin class"))

(defgeneric (setf slot-value-using-class) (new-value class object slot))

(defun (setf slot-value-using-class-aux) (new-value object slot)
  (let ((location (slot-definition-location slot)))
    (if (consp location)
	(setf (car location) new-value)
  	(setf (slot-contents (heap-instance-slots object) location)
	      new-value))))

(defmethod (setf slot-value-using-class)
  (new-value
   (class standard-class)
   object
   (slot standard-effective-slot-definition))
  (setf (slot-value-using-class-aux object slot) new-value))

(defmethod (setf slot-value-using-class)
  (new-value
   (class funcallable-standard-class)
   object
   (slot standard-effective-slot-definition))
  (setf (slot-value-using-class-aux object slot) new-value))

(defmethod (setf slot-value-using-class)
  (new-value
   (class built-in-class)
   object
   slot)
  (declare (ignore object))
  (error "no slots in an instance of a builtin class"))

(defun slot-value (object slot-name)
  (let ((class (class-of object)))
    ;; FIXME: check that the object is up to date.  
    ;; 
    ;; The first element of the contents vector is the list of
    ;; effective slots of the class of the object.
    (let* ((slots (slot-contents (heap-instance-slots object) 0))
	   (slot (find slot-name slots :test #'eq :key #'slot-definition-name)))
      (if (null slot)
	  (slot-missing class object slot-name 'slot-value)
	  (slot-value-using-class class object slot)))))

(defun (setf slot-value) (new-value object slot-name)
  (let ((class (class-of object)))
    ;; FIXME: check that the object is up to date.  
    ;; 
    ;; The first element of the contents vector is the list of
    ;; effective slots of the class of the object.
    (let* ((slots (slot-contents (heap-instance-slots object) 0))
	   (slot (find slot-name slots :test #'eq :key #'slot-definition-name)))
      (if (null slot)
	  (slot-missing class object slot-name 'slot-value)
	  (setf (slot-value-using-class class object slot) new-value)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; SLOT-BOUNDP SLOT-BOUNDP-USING-CLASS

(defgeneric slot-boundp-using-class (class object slot))

(defun slot-boundp-using-class-aux (object slot)
  (let ((location (slot-definition-location slot)))
    (not (eq (if (consp location)
		 (car location)
		 (slot-contents (heap-instance-slots object) location))
	     *unbound-value*))))

(defmethod slot-boundp-using-class ((class standard-class)
				    object
				    (slot standard-effective-slot-definition))
  (slot-boundp-using-class-aux object slot))

(defmethod slot-boundp-using-class ((class funcallable-standard-class)
				    object
				    (slot standard-effective-slot-definition))
  (slot-boundp-using-class-aux object slot))

(defmethod slot-boundp-using-class ((class built-in-class)
				    object
				    slot)
  (declare (ignore object))
  (error "no slots in an instance of a builtin class"))

(defun slot-boundp (object slot-name)
  ;; FIXME: We must check that the object is a standard instance.
  (let ((slot (find-slot object slot-name))
	(class (class-of object)))
    ;; FIXME: check that the object is up to date.  
    (slot-boundp-using-class class object slot)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; SLOT-MAKUNBOUND, SLOT-MAKUNBOUND-USING-CLASS.

(defgeneric slot-makunbound-using-class (class object slot))

(defun slot-makunbound-using-class-aux (object slot)
  (let ((location (slot-definition-location slot)))
    (if (consp location)
	(setf (car location) *unbound-value*)
  	(setf (slot-contents (heap-instance-slots object) location)
	      *unbound-value*)))
  nil)

(defmethod slot-makunbound-using-class
  ((class standard-class)
   object
   (slot standard-effective-slot-definition))
  (slot-makunbound-using-class-aux object slot))

(defmethod slot-makunbound-using-class
  ((class funcallable-standard-class)
   object
   (slot standard-effective-slot-definition))
  (slot-makunbound-using-class-aux object slot))

(defmethod slot-makunbound-using-class
  ((class built-in-class)
   object
   slot)
  (error "no slots in an instance of a builtin class"))

(defun slot-makunbound (object slot-name)
  (let* ((slot (find-slot object slot-name))
	 (class (class-of object)))
    (if (null slot)
	(slot-missing class object slot-name 'slot-makunbound)
	(slot-makunbound-using-class class object slot))))
