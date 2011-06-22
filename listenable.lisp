; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(in-package :events)

(defclass listenable ()
  ((listeners :initform '()
              :reader listeners)
   (provided-events :initform '()
                    :initarg :provided-events
                    :reader provided-events)))

(defmethod provide-events ((listenable listenable) &rest events)
  (with-slots (provided-events) listenable
    (if (null provided-events)
        (setf provided-events (delete-duplicates events))
        (setf provided-events 
              (delete-duplicates (nconc provided-events events))))))

(defmethod provides-event-p ((listenable listenable) event)
  (with-slots (provided-events) listenable
    (find event provided-events)))

(defmethod send-event ((listenable listenable) event)
  (with-slots (provided-events listeners) listenable
    (unless (find (event-type event) provided-events)
      (error 'invalid-event
             :reason :not-provided
             :listenable listenable
             :event-type (event-type event)))
    (dolist (listener (getf listeners (event-type event)))
      (let ((handler (select-handler listener (event-type event))))
        (if (not (null handler))
            (funcall handler listener event)
            (warn "~S listens for event ~S but doesn't specify a handler."
                  listener (event-type event)))))))
