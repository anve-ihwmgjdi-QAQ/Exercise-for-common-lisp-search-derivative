(in-package "CLOS-EXTEND")

(defmacro defclass! (name direct-superclasses direct-slots &rest options)
  (let* ((var-name (make-symbol "VAR-NAME"))
         (body     (make-symbol "BODY"))
         (slots-initarg (mapcar #'(lambda (x)
                                    (read-from-string (format nil ":~A" x)))
                                direct-slots))
         (initargs-list (do ((initargs direct-slots (cdr initargs))
                             (initform (mapcar #'(lambda (x) `',x)
                                               slots-initarg)
                                       (cdr initform))
                             (result   nil))
                            ((null initargs) result)
                          (push (car initargs) result)
                          (push (car initform) result))))
    `(progn
       (defclass ,name ,direct-superclasses
         ,(mapcar #'(lambda (slot-name initarg)
                      (list slot-name
                        ':accessor (intern (format nil "~A.~A" name slot-name))
                        ':initarg initarg))
                  direct-slots slots-initarg)
         ,@options)
       (defmacro ,name (,var-name ,@direct-slots &body ,body)
         `(let ((,,var-name (make-instance ',',name ,@,`(list ,@initargs-list))))
            ,@,body))
       (defmacro ,(intern (format nil "~A~A" 'def name)) (,var-name ,@direct-slots)
         `(defparameter ,,var-name (make-instalce ,',name ,@,`(list ,@initargs-list)))))))