; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(asdf:defsystem "events"
  :author "Jens Thiede"
  :license "BSD-style"
  :depends-on ("meta-package")
  :serial t
  :components ((:file "package")
               (:file "conditions")
               (:file "event")
               (:file "listener")
               (:file "listenable")
               (:file "communication")
               (:file "event-converter")
               (:file "export")))