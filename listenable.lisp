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
