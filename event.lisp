; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(in-package :events)

(declaim (inline event-type event-data))
(defun event-type (event) (car event))
(defun event-data (event) (cdr event))

(defmacro with-event-keys (keys event &body body)
  (let ((data (gensym "event")))
    `(let* ((,data (cdr ,event))
            ,@(loop for key in keys collect
                   `(,key (getf ,data ,(intern (symbol-name key) "KEYWORD")))))
       ,@body)))