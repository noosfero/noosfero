require File.dirname(__FILE__) + '/../test_helper'

class NotifyActivityToProfilesJobTest < ActiveSupport::TestCase

  should 'create the ActionTrackerNotification' do
    person = fast_create(Person)
    community  = fast_create(Community)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id)
    p1, p2, m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)
    fast_create(Friendship, :person_id => person.id, :friend_id => p1.id)
    fast_create(Friendship, :person_id => person.id, :friend_id => p2.id)
    fast_create(RoleAssignment, :accessor_id => m1.id, :role_id => 3, :resource_id => community.id)
    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id, community.id)
    job.perform
    process_delayed_job_queue
    assert_equal 5, ActionTrackerNotification.count
  end

end
