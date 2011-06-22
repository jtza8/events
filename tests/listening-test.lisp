; Use of this source code is governed by a BSD-style
; license that can be found in the license.txt file
; in the root directory of this project.

(in-package :events)

(defclass listening-test (test-case)
  ())

(def-test-method test-events ((test listening-test))
  (let ((event '(:event :a a :b b)))
    (assert-equal (event-type event) :event)
    (assert-equal (event-data event) '(:a a :b b))
    (with-event-keys (a b) event
      (assert-equal 'a a)
      (assert-equal 'b b))))

(def-test-method test-listenable ((test listening-test))
  (let ((listenable (make-instance 'dummy-listenable
                                   :provide-events '(:type-a :type-b))))
    (assert-true (provides-event-p listenable :type-a))
    (assert-true (provides-event-p listenable :type-b))
    (assert-false (provides-event-p listenable :type-c))
    (provide-events listenable :type-c :type-d)
    (assert-true (provides-event-p listenable :type-c))
    (assert-true (provides-event-p listenable :type-d))))

(def-test-method test-listener ((test listening-test))
  (let ((listener (make-instance 'dummy-listener)))
    (assert-true (desires-event-p listener :dummy-event))
    (assert-false (desires-event-p listener :type-a))
    (desire-events listener :type-a #'event-handler :type-b #'event-handler)
    (assert-true (desires-event-p listener :dummy-event))
    (assert-true (desires-event-p listener :type-a))
    (assert-true (desires-event-p listener :type-b))))

(def-test-method test-communication ((test listening-test))
  (let ((listener (make-instance 'dummy-listener
                                 :desired-events '(:type-a :type-b)))
        (listenable (make-instance 'dummy-listenable
                                   :provide-events '(:type-a :type-b :type-c))))
    (subscribe listenable listener)
    (assert-true (subscription-request-called-p listener))
    (assert-equal nil (latest-event listener))
    (send-event listenable '(:type-a :foo foo))
    (assert-equal (event-type (latest-event listener)) :type-a)
    (send-event listenable '(:type-b :foo foo))
    (assert-equal (event-type (latest-event listener)) :type-b)
    (send-event listenable '(:type-c :foo bar))
    (assert-equal (event-type (latest-event listener)) :type-b)
    (assert-condition 'invalid-event (send-event listenable '(:type-d)))
    (assert-condition 'invalid-event (subscribe listenable listener :type-d))
    (assert-false (unsubscription-notice-called-p listener))
    (unsubscribe listenable listener :type-a)
    (assert-true (unsubscription-notice-called-p listener))
    (send-event listenable '(:type-a))
    (assert-equal :type-b (event-type (latest-event listener)))
    (setf (latest-event listener) '(:type-z))
    (unsubscribe listenable listener)
    (send-event listenable '(:type-b))
    (assert-equal :type-z (event-type (latest-event listener)))))
