require_relative "../test_helper"

class NotifyActivityToProfilesJobTest < ActiveSupport::TestCase

  should 'notify just the community in tracker with add_member_in_community verb' do
    person = fast_create(Person)
    community  = fast_create(Community)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :target_id => community.id, :verb => 'add_member_in_community')
    assert NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY.include?(action_tracker.verb)
    p1, p2, m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)
    fast_create(Friendship, :person_id => person.id, :friend_id => p1.id)
    fast_create(Friendship, :person_id => person.id, :friend_id => p2.id)
    fast_create(RoleAssignment, :accessor_id => m1.id, :role_id => 3, :resource_id => community.id)
    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    job.perform
    process_delayed_job_queue

    assert_equal 1, ActionTrackerNotification.count
    [community].each do |profile|
      notification = ActionTrackerNotification.find_by profile_id: profile.id
      assert_equal action_tracker, notification.action_tracker
    end
  end

  should 'notify just the users and his followers tracking user actions' do
    person = fast_create(Person)
    community  = fast_create(Community)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :verb => 'create_article')
    refute NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY.include?(action_tracker.verb)
    p1, p2, m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)

    circle1 = Circle.create!(:person=> p1, :name => "Zombies", :profile_type => 'Person')
    circle2 = Circle.create!(:person=> p2, :name => "Zombies", :profile_type => 'Person')
    circle = Circle.create!(:person=> person, :name => "Zombies", :profile_type => 'Person')

    fast_create(ProfileFollower, :profile_id => person.id, :circle_id => circle1.id)
    fast_create(ProfileFollower, :profile_id => person.id, :circle_id => circle2.id)
    fast_create(ProfileFollower, :profile_id => m1.id, :circle_id => circle.id)

    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    job.perform
    process_delayed_job_queue

    assert_equal 3, ActionTrackerNotification.count
    [person, p1, p2].each do |profile|
      notification = ActionTrackerNotification.find_by profile_id: profile.id
      assert_equal action_tracker, notification.action_tracker
    end
  end

  should 'notify only marked people on marked scraps' do
    profile = create_user('scrap-creator').person
    c1 = Circle.create!(:name => 'Family', :person => profile, :profile_type => Person)
    p1 = create_user('emily').person
    p2 = create_user('wollie').person
    not_marked = create_user('jack').person
    not_marked.add_friend(p1)
    not_marked.add_friend(p2)
    not_marked.add_friend(profile)
    ProfileFollower.create!(:profile => p1, :circle => c1)
    ProfileFollower.create!(:profile => p2, :circle => c1)
    ProfileFollower.create!(:profile => not_marked, :circle => c1)

    scrap = Scrap.create!(:content => 'Secret message.', :sender_id => profile.id, :receiver_id => profile.id, :marked_people => [p1,p2])
    process_delayed_job_queue

    assert p1.tracked_notifications.where(:target => scrap).present?
    assert p2.tracked_notifications.where(:target => scrap).present?
    assert not_marked.tracked_notifications.where(:target => scrap).blank?
  end

  should 'not notify the communities members' do
    person = fast_create(Person)
    community  = fast_create(Community)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :target_id => community.id, :verb => 'create_article')
    refute NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY.include?(action_tracker.verb)
    m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)
    fast_create(RoleAssignment, :accessor_id => m1.id, :role_id => 3, :resource_id => community.id)
    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    job.perform
    process_delayed_job_queue

    assert_equal 4, ActionTrackerNotification.count
    [person, community, m1, m2].each do |profile|
      notification = ActionTrackerNotification.find_by profile_id: profile.id
      assert_equal action_tracker, notification.action_tracker
    end
  end

  should 'notify users its followers, the community and its members' do
    person = fast_create(Person)
    community  = fast_create(Community)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :target_id => community.id, :verb => 'create_article')
    refute NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY.include?(action_tracker.verb)
    p1, p2, m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)

    circle1 = Circle.create!(:person=> p1, :name => "Zombies", :profile_type => 'Person')
    fast_create(ProfileFollower, :profile_id => person.id, :circle_id => circle1.id)

    fast_create(RoleAssignment, :accessor_id => m1.id, :role_id => 3, :resource_id => community.id)
    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    job.perform
    process_delayed_job_queue
    assert_equal 5, ActionTrackerNotification.count
    [person, community, p1, m1, m2].each do |profile|
      notification = ActionTrackerNotification.find_by profile_id: profile.id
      assert_equal action_tracker, notification.action_tracker
    end
  end

  should 'notify only the community if it is private' do
    person = fast_create(Person)
    private_community  = fast_create(Community, :public_profile => false)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :target_id => private_community.id, :verb => 'create_article')
    refute NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY.include?(action_tracker.verb)
    p1, p2, m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)
    fast_create(Friendship, :person_id => person.id, :friend_id => p1.id)
    fast_create(Friendship, :person_id => person.id, :friend_id => p2.id)
    fast_create(RoleAssignment, :accessor_id => m1.id, :role_id => 3, :resource_id => private_community.id)
    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => private_community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    job.perform
    process_delayed_job_queue

    assert_equal 1, ActionTrackerNotification.count
    [person,  p1, p2, m1, m2].each do |profile|
      notification = ActionTrackerNotification.find_by profile_id: profile.id
      assert notification.nil?
    end

    notification = ActionTrackerNotification.find_by profile_id: private_community.id
    assert_equal action_tracker, notification.action_tracker
  end

  should 'not notify the community tracking join_community verb' do
    person = fast_create(Person)
    community  = fast_create(Community)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :target_id => community.id, :verb => 'join_community')
    refute NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY.include?(action_tracker.verb)
    p1, p2, m1, m2 = fast_create(Person), fast_create(Person), fast_create(Person), fast_create(Person)

    circle1 = Circle.create!(:person=> p1, :name => "Zombies", :profile_type => 'Person')
    circle2 = Circle.create!(:person=> p2, :name => "Zombies", :profile_type => 'Person')

    fast_create(ProfileFollower, :profile_id => person.id, :circle_id => circle1.id)
    fast_create(ProfileFollower, :profile_id => person.id, :circle_id => circle2.id)

    fast_create(RoleAssignment, :accessor_id => m1.id, :role_id => 3, :resource_id => community.id)
    fast_create(RoleAssignment, :accessor_id => m2.id, :role_id => 3, :resource_id => community.id)
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    job.perform
    process_delayed_job_queue

    assert_equal 5, ActionTrackerNotification.count
    [person, p1, p2, m1, m2].each do |profile|
      notification = ActionTrackerNotification.find_by profile_id: profile.id
      assert_equal action_tracker, notification.action_tracker
    end
  end

  should "the NOTIFY_ONLY_COMMUNITY constant has all the verbs tested" do
    notify_community_verbs = ['add_member_in_community']
    assert_equal [], notify_community_verbs - NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY
    assert_equal [], NotifyActivityToProfilesJob::NOTIFY_ONLY_COMMUNITY - notify_community_verbs
  end

  should "the NOT_NOTIFY_COMMUNITY constant has all the verbs tested" do
    not_notify_community_verbs = ['join_community']
    assert_equal [], not_notify_community_verbs - NotifyActivityToProfilesJob::NOT_NOTIFY_COMMUNITY
    assert_equal [], NotifyActivityToProfilesJob::NOT_NOTIFY_COMMUNITY - not_notify_community_verbs
  end

  should 'cancel notify when target no more exists' do
    person = fast_create(Person)
    friend = fast_create(Person)
    fast_create(Friendship, :person_id => person.id, :friend_id => friend.id)
    action_tracker = fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => person.id, :target_type => 'Profile', :verb => 'create_article')
    ActionTrackerNotification.delete_all
    job = NotifyActivityToProfilesJob.new(action_tracker.id)
    person.destroy
    job.perform
    process_delayed_job_queue
    assert_equal 0, ActionTrackerNotification.count
  end

end
