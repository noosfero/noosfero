require_relative "../test_helper"

class ActionTrackerNotificationTest < ActiveSupport::TestCase

  should "have the profile" do
    a = ActionTrackerNotification.new
    a.valid?
    assert a.errors[:profile_id.to_s].present?

    a.profile_id= 1
    a.valid?
    refute a.errors[:profile_id.to_s].present?
  end

  should "have the action tracker" do
    a = ActionTrackerNotification.new
    a.valid?
    assert a.errors[:action_tracker_id.to_s].present?

    a.action_tracker_id= 1
    a.valid?
    refute a.errors[:action_tracker_id.to_s].present?
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
    assert atn.errors[:action_tracker_id.to_s].present?

    atn.profile_id = 2
    atn.valid?
    refute atn.errors[:action_tracker_id.to_s].present?
  end

  should "the action_tracker_id be unique on scope of profile when created by ActionTracker::Record association" do
    at = fast_create(ActionTracker::Record)
    person = fast_create(Person)
    assert_equal [], at.action_tracker_notifications
    at.action_tracker_notifications<< build(ActionTrackerNotification, :profile => person)
    at.reload

    assert_equal 1, at.action_tracker_notifications.count
    last_notification = at.action_tracker_notifications.first

    at.action_tracker_notifications<< build(ActionTrackerNotification, :profile => person)
    at.reload
    assert_equal [last_notification], at.action_tracker_notifications
  end

  should "have comments through action_tracker" do
    person = fast_create(Person)
    friend = fast_create(Person)
    person.add_friend(friend)
    process_delayed_job_queue
    activity = ActionTracker::Record.where(verb: 'new_friendship').last
    notification = ActionTrackerNotification.find_by action_tracker_id: activity.id

    comment = create(Comment, :source => activity, :author => person)
    assert_equal activity.comments, notification.comments
  end

  should "have comments through article action_tracker" do
    user = User.current = create_user
    person = user.person
    article = create(TextileArticle, :profile_id => person.id)
    process_delayed_job_queue
    notification = ActionTrackerNotification.last

    comment = create(Comment, :source => article, :author => person)

    assert_equal article.activity.comments, notification.comments
  end

end
