; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(in-package :events)

(defclass dummy-listenable (listenable)
  ())

(defmethod initialize-instance :after ((listenable listenable)
                                       &key provide-events)
  (apply #'provide-events listenable provide-events))