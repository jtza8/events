; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(asdf:defsystem "events-tests"
  :author "Jens Thiede"
  :license "BSD-style"
  :depends-on ("xlunit" "events")
  :serial t
  :components ((:file "package")
               (:file "dummy-listener")
               (:file "dummy-listenable")
               (:file "listening-test")))