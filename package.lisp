; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(defpackage #:events
  (:use :cl :cl-user :meta-package))

(in-package :events)
(eval-when (:compile-toplevel)
  (defconstant +nothing+ (gensym "NOTHING-")))