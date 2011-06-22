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
  (let ((listener-1 (make-instance 'dummy-listener
                                 :desired-events '(:type-a :type-b)))
        (listener-2 (make-instance 'dummy-listener
                                 :desired-events '(:type-a :type-b)))
        (listenable (make-instance 'dummy-listenable
                                   :provide-events '(:type-a :type-b :type-c))))
    (subscribe listenable listener-1)
    (subscribe listenable listener-2)
    (assert-true (subscription-request-called-p listener-1))
    (assert-equal nil (latest-event listener-1))
    (send-event listenable '(:type-a))
    (assert-equal (event-type (latest-event listener-1)) :type-a)
    (send-event listenable '(:type-b))
    (assert-equal (event-type (latest-event listener-1)) :type-b)
    (send-event listenable '(:type-a) listener-2)
    (assert-equal (event-type (latest-event listener-1)) :type-b)
    (assert-equal (event-type (latest-event listener-2)) :type-a)
    (send-event listenable '(:type-c))
    (assert-equal (event-type (latest-event listener-1)) :type-b)
    (assert-condition 'invalid-event (send-event listenable '(:type-d)))
    (assert-condition 'invalid-event (subscribe listenable listener-1 :type-d))
    (assert-true (subscriber-p listenable listener-1 :type-a))
    (assert-false (unsubscription-notice-called-p listener-1))
    (unsubscribe listenable listener-1 :type-a)
    (assert-true (unsubscription-notice-called-p listener-1))
    (assert-false (subscriber-p listenable listener-1 :type-a))
    (send-event listenable '(:type-a))
    (assert-equal :type-b (event-type (latest-event listener-1)))
    (setf (latest-event listener-1) '(:type-z))
    (unsubscribe listenable listener-1)
    (send-event listenable '(:type-b))
    (assert-equal :type-z (event-type (latest-event listener-1)))))
