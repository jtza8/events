; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(in-package :events)

(defmethod subscription-request ((listener listener) (listenable listenable) 
                              event-type)
  t)

(defmethod subscribe ((listenable listenable) (listener listener)
                         &optional event-type)
  (with-slots (listeners provided-events) listenable
    (when (null event-type)
      (when (null (subscription-request listener listenable nil))
        (return-from subscribe))
      (loop for (event) on (desired-events listener) by #'cddr
            do (when (find event provided-events)
                 (subscribe listenable listener event)))
      (return-from subscribe))
    (assert (find event-type provided-events) (event-type)
            'invalid-event
            :reason :unslistenable
            :event-type event-type)
    (unless (select-handler listener event-type)
      (warn "~S requested to listen to event ~S but doesn't provide a handler."
            listener event-type))
    (when (null (subscription-request listener listenable event-type))
      (return-from subscribe))
    (if (eq (getf listeners event-type) nil)
        (progn (push (list listener) listeners)
               (push event-type listeners))
        (pushnew listener (getf listeners event-type)))))

(defmethod unsubscription-notice ((listener listener) (listenable listenable)
                                    event)
  ())

(defmethod unsubscribe ((listenable listenable) (listener listener)
                            &optional event-type)
  (unsubscription-notice listener listenable event-type)
  (when (null event-type)
    (loop for (event nil) on (desired-events listener) by #'cddr
          do (unsubscribe listenable listener event))
    (return-from unsubscribe))
  (with-slots (listeners) listenable
    (let* ((event-listeners (getf listeners event-type +nothing+)))
      (assert (not (eq event-listeners +nothing+)) (event-type)
              'invalid-event
              :reason :not-provided
              :event-type event-type
              :listenable listenable)
      (setf (getf listeners event-type)
            (delete listener (getf listeners event-type))))))

(defmethod subscriber-p ((listenable listenable) (listener listener) event-type)
  (find listener (getf (listeners listenable) event-type)))

(defmethod send-event ((listenable listenable) event &rest targets)
  (with-slots (provided-events listeners) listenable
    (unless (find (event-type event) provided-events)
      (error 'invalid-event
             :reason :not-provided
             :listenable listenable
             :event-type (event-type event)))
    (dolist (listener (if (null targets)
                          (getf listeners (event-type event))
                          targets))
      (let ((handler (select-handler listener (event-type event))))
        (if (not (null handler))
            (funcall handler listener event)
            (warn "Couldn't send event ~s to ~s because ~
                   it doesn't specify a handler for such an event."
                  listener (event-type event)))))))