require_relative '../test_helper'

class EventBlockTest < ActiveSupport::TestCase

  def setup
    @env = Environment.default
    @env.enable_plugin('EventPlugin')

    @p1  = fast_create(Person, :environment_id => @env.id)
    @event = fast_create(Event, :name => 'Event p1 A', :profile_id => @p1.id,
                          :start_date => Date.today+30)
    fast_create(Event, :name => 'Event p1 B', :profile_id => @p1.id,
                  :start_date => Date.today+10)

    @p2  = fast_create(Community, :environment_id => @env.id)
    fast_create(Event, :name => 'Event p2 A', :profile_id => @p2.id,
                  :start_date => Date.today-10)
    fast_create(Event, :name => 'Event p2 B', :profile_id => @p2.id,
                  :start_date => Date.today-30)

    box = fast_create(Box, :owner_id => @p1)
    @block = EventPlugin::EventBlock.new(:limit => 99, :future_only => false, :box => box)
  end

  def set_portal(env, portal)
    env.portal_community = portal
    env.enable('use_portal_community')
    env.save!
  end

  should 'select source as env, while visiting the profile' do
    @block.box.owner = @p1
    @block.all_env_events = true

    assert_equal @env, @block.events_source
    assert_equal 4, @block.events.length

    set_portal(@env, @p2)

    assert_equal @env, @block.events_source
    assert_equal 4, @block.events.length
  end

  should 'select source as env, while visiting an env page' do
    @block.box.owner = @env
    @block.all_env_events = true

    assert_equal @env, @block.events_source
    assert_equal 4, @block.events.length

    set_portal @env, @p2

    assert_equal @env, @block.events_source
    assert_equal 4, @block.events.length
  end

  should 'select source as portal_community, while visiting an env page' do
    set_portal @env, @p2

    @block.box.owner = @env.portal_community
    @block.all_env_events = false

    assert_equal @p2, @block.events_source
    assert_equal 2, @block.events.length
  end

  should 'select source as profile, while visiting its page' do
    @block.stubs(:owner).returns(@p1)
    @block.all_env_events = false

    assert_equal @p1, @block.events_source
    assert_equal 2, @block.events.length

    set_portal @env, @p2

    assert_equal @p1, @block.events_source
    assert_equal 2, @block.events.length
  end

  should 'show unlimited time distance events' do
    @block.box.owner = @env
    @block.all_env_events = true
    @block.date_distance_limit = 0

    assert_equal 4, @block.events.length
  end

  should 'only show 20 days distant events' do
    @block.box.owner = @env
    @block.all_env_events = true
    @block.date_distance_limit = 20

    assert_equal 2, @block.events.length
  end

  should 'show future and past events' do
    @block.box.owner = @env
    @block.all_env_events = true
    @block.future_only = false

    assert_equal 4, @block.events.length
  end

  should 'show only future events' do
    @block.box.owner = @env
    @block.all_env_events = true
    @block.future_only = true

    assert_equal 2, @block.events.length
  end

  should 'show only published events' do
    @block.box.owner = @env
    @block.all_env_events = true
    @event.published = false
    @event.save!

    assert_equal 3, @block.events.length
  end

  should 'filter events from non public profiles' do
    person  = create_user('testuser', :environment_id => @env.id).person
    person.public_profile = false
    person.save!

    visibility_content_test_from_a_profile person
  end

  should 'filter events from non visible profiles' do
    person = create_user('testuser', :environment_id=>@env.id).person
    person.visible = false
    person.save!

    visibility_content_test_from_a_profile person
  end

  def visibility_content_test_from_a_profile(profile)
    @block.box.owner = @env
    ev = Event.create!(:name => '2 de Julho', :profile => profile)
    @block.all_env_events = true

    # Do not list event from private profile for non logged visitor
    refute  @block.events.include?(ev)
    assert_equal 4, @block.events.length

    # Do not list event from private profile for non unprivileged user
    refute  @block.events.include?(ev)
    assert_equal 4, @block.events(@p1).length

    # Must to list event from private profile for a friend
    AddFriend.create!(:requestor => @p1, :target => profile).finish

    assert @block.events(@p1).include?(ev)
    assert_equal 5, @block.events(@p1).length

    # Must to list event from private profile for itself
    assert @block.events(profile).include?(ev)
    assert_equal 5, @block.events(profile).length
  end
end
