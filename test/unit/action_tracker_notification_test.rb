require File.dirname(__FILE__) + '/../test_helper'

class ActionTrackerNotificationTest < ActiveSupport::TestCase

  should "have the profile" do
    a = ActionTrackerNotification.new
    a.valid?
    assert a.errors.invalid?(:profile_id)

    a.profile_id= 1
    a.valid?
    assert !a.errors.invalid?(:profile_id)
  end

  should "have the action tracker" do
    a = ActionTrackerNotification.new
    a.valid?
    assert a.errors.invalid?(:action_tracker_id)

    a.action_tracker_id= 1
    a.valid?
    assert !a.errors.invalid?(:action_tracker_id)
  end

  should "be associated to Person" do
    person = fast_create(Person)
    a = ActionTrackerNotification.new
    assert_nothing_raised do
      a.profile = person
    end
  end

  should "be associated to ActionTracker" do
    action_tracker = ActionTracker::Record.new
    a = ActionTrackerNotification.new
    assert_nothing_raised do
      a.action_tracker= action_tracker
    end
  end

  should "destroy the notifications if the activity is destroyed" do
    action_tracker = fast_create(ActionTracker::Record)
    count = ActionTrackerNotification.count
    fast_create(ActionTrackerNotification, :action_tracker_id => action_tracker.id, :profile_id => 1)
    fast_create(ActionTrackerNotification, :action_tracker_id => action_tracker.id, :profile_id => 2)
    fast_create(ActionTrackerNotification, :action_tracker_id => action_tracker.id, :profile_id => 3)
    action_tracker.destroy
    assert_equal count, ActionTrackerNotification.count
  end

  should "the action_tracker_id be unique on scope of profile" do
    atn = fast_create(ActionTrackerNotification, :action_tracker_id => 1, :profile_id => 1)
    assert atn.valid?

    atn = ActionTrackerNotification.new(:action_tracker_id => 1, :profile_id => 1)
    atn.valid?
    assert atn.errors.invalid?(:action_tracker_id)

    atn.profile_id = 2
    atn.valid?
    assert !atn.errors.invalid?(:action_tracker_id)
  end

  should "the action_tracker_id be unique on scope of profile when created by ActionTracker::Record association" do
    at = fast_create(ActionTracker::Record)
    person = fast_create(Person)
    assert_equal [], at.action_tracker_notifications
    at.action_tracker_notifications<< ActionTrackerNotification.new(:profile => person)
    at.reload

    assert_equal 1, at.action_tracker_notifications.count
    last_notification = at.action_tracker_notifications.first

    at.action_tracker_notifications<< ActionTrackerNotification.new(:profile => person)
    at.reload
    assert_equal [last_notification], at.action_tracker_notifications
  end

end
