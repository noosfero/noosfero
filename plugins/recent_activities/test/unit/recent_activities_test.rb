require 'test_helper'

class RecentActivitiesPluginTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(RecentActivitiesPlugin)
  end

  should 'have label for events' do
    person = fast_create(Person)
    event = build(Event, { name: 'Event', start_date: DateTime.new(2020, 1, 1) })
    event.profile = person
    event.save!
    activity = create_activity(person, event)
    assert_equal 'events', activity.label
  end

  should 'have label for communities' do
    person = fast_create(Person)
    community = fast_create(Community)
    activity = create_activity(person, community)
    assert_equal 'communities', activity.label
  end

  should 'have label for people' do
    person = fast_create(Person)
    friendship = fast_create(Friendship)
    activity = create_activity(person, friendship)
    assert_equal 'people', activity.label
  end

  should 'have label for posts' do
    person = fast_create(Person)
    article = fast_create(Article)
    activity = create_activity(person, article)
    assert_equal 'posts', activity.label
  end

  protected

  def create_activity(person, target)
    activity = ActionTracker::Record.create! verb: :leave_scrap, user: person, target: target
    ProfileActivity.create! profile_id: target.id, activity: activity
    activity.reload
  end
end
