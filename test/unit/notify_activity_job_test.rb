require File.dirname(__FILE__) + '/../test_helper'

class NotifyActivityJobTest < ActiveSupport::TestCase

  should 'create the ActionTrackerNotification' do
    action_tracker = fast_create(ActionTracker::Record)
    profile  = fast_create(Profile)
    count = ActionTrackerNotification.count
    job = NotifyActivityJob.new(action_tracker.id, profile.id)
    job.perform

    assert_equal count + 1, ActionTrackerNotification.count
    last = ActionTrackerNotification.last
    assert_equal action_tracker, last.action_tracker
    assert_equal profile, last.profile
  end

end
