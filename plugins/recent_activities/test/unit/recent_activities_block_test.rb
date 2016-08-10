require_relative '../test_helper'

class RecentActivitiesBlockTest < ActiveSupport::TestCase
  should 'describe itself' do
    assert_not_equal Block.description, RecentActivitiesPlugin::ActivitiesBlock.description
  end

  should 'is editable' do
    block = RecentActivitiesPlugin::ActivitiesBlock.new
    assert block.editable?
  end

  should 'return last activities' do
    profile = create_user('testuser').person
    a1 = fast_create(ActionTracker::Record, user_id: profile.id, created_at: Time.now, updated_at: Time.now)
    a2 = fast_create(ActionTracker::Record, user_id: profile.id, created_at: Time.now, updated_at: Time.now)
    ProfileActivity.create! profile_id: profile.id, activity: a1
    ProfileActivity.create! profile_id: profile.id, activity: a2

    block = RecentActivitiesPlugin::ActivitiesBlock.new
    block.stubs(:owner).returns(profile)

    assert_equal [a2, a1].map(&:id), block.activities.map(&:id)
  end

  should 'return last activities with limit' do
    profile = create_user('testuser').person
    a1 = fast_create(ActionTracker::Record, user_id: profile.id, created_at: Time.now, updated_at: Time.now)
    a2 = fast_create(ActionTracker::Record, user_id: profile.id, created_at: Time.now, updated_at: Time.now)
    ProfileActivity.create! profile_id: profile.id, activity: a1
    ProfileActivity.create! profile_id: profile.id, activity: a2

    block = RecentActivitiesPlugin::ActivitiesBlock.new
    block.stubs(:owner).returns(profile)
    block.limit = 1

    assert_equal [a2].map(&:id), block.activities.map(&:id)
  end

  should 'return only action tracker records as activities' do
    profile = create_user('testuser').person
    friend = create_user('friend').person
    scrap = create(Scrap, defaults_for_scrap(sender: friend, receiver: profile))
    a1 = fast_create(ActionTracker::Record, user_id: profile.id, created_at: Time.now, updated_at: Time.now)
    a2 = fast_create(ActionTracker::Record, user_id: profile.id, created_at: Time.now, updated_at: Time.now)
    ProfileActivity.create! profile_id: profile.id, activity: a1
    ProfileActivity.create! profile_id: profile.id, activity: a2

    block = RecentActivitiesPlugin::ActivitiesBlock.new
    block.stubs(:owner).returns(profile)

    assert_equal [a2, a1, scrap], block.owner.activities.map(&:activity)
    assert_equal [a2, a1], block.activities
  end
end

require 'boxes_helper'

class RecentActivitiesBlockViewTest < ActionView::TestCase
  include BoxesHelper

  should 'return activities in api_content' do
    profile = create_user('testuser').person

    a = fast_create(ActionTracker::Record, user_id: profile.id, created_at: Time.now, updated_at: Time.now)
    ProfileActivity.create! profile_id: profile.id, activity: a

    block = RecentActivitiesPlugin::ActivitiesBlock.new
    block.stubs(:owner).returns(profile)

    api_activity = block.api_content['activities'].last
    assert_equal [a.id], block.api_content['activities'].map{ |a| a[:id] }
    assert_not_nil api_activity[:label]
    assert_nil api_activity[:start_date]
  end

  should 'return event information in api_content' do
    person = fast_create(Person)
    event = build(Event, { name: 'Event', start_date: DateTime.new(2020, 1, 1) })
    event.profile = person
    event.save!
    activity = create_activity(person, event)

    block = RecentActivitiesPlugin::ActivitiesBlock.new
    block.stubs(:owner).returns(person)

    api_activity = block.api_content['activities'].last
    assert_not_nil api_activity[:start_date]
  end

  protected

  def create_activity(person, target)
    activity = ActionTracker::Record.create! verb: :leave_scrap, user: person, target: target
    ProfileActivity.create! profile_id: target.id, activity: activity
    activity.reload
  end
end
