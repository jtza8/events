; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(in-package :events)

(internal reason-reporter)
(defmacro reason-reporter (condition stream reason-slot (&rest slots)
                           &body cases)
  `(with-slots (,reason-slot ,@slots) ,condition
     (format ,stream
             (ecase ,reason-slot
               ,@(loop for case in cases
                       if (> (length case) 2)
                         collect `(,(car case)
                                    (format nil ,@(subseq case 1)))
                       else
                         collect case)))))

(define-condition invalid-event (error)
  ((reason :initarg :reason
           :initform (error "Must specify :reason.")
           :reader reason)
   (listenable :initarg :listenable
               :initform nil
               :reader listenable)
   (event-type :initarg :event-type
               :initform nil
               :reader event-type))
  (:report (lambda (condition stream)
             (reason-reporter condition stream reason (event-type listenable)
               (:unlistenable "Cannot listen to event type ~s." event-type)
               (:not-provided "Event type ~s is not provided by listenable ~s."
                              event-type listenable)))))