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

end
