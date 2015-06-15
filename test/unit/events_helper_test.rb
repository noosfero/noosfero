require_relative "../test_helper"

class EventsHelperTest < ActiveSupport::TestCase

  include EventsHelper

  should 'list events' do
    user = create_user('userwithevents').person
    stubs(:user).returns(user)

    event1 = Event.new(name: "Event 1", start_date: Date.today, end_date: (Date.today + 1.day), address: 'The Shire')
    event1.profile = user
    event1.save

    event2 = Event.new(name: 'Event 2', start_date: Date.today, end_date: (Date.today + 1.day), address: 'Valfenda')
    event2.profile = user
    event2.save

    result = list_events(Date.today, [event1, event2])

    assert_match /Event 1/, result
    assert_match /Event 2/, result
  end

  should 'populate calendar with links on days that have events' do
    user = create_user('userwithevents').person
    stubs(:user).returns(user)
    event = fast_create(Event, :profile_id => user.id)
    date = event.start_date
    calendar = populate_calendar(date, Environment.default.events)
    assert_includes calendar, [date, true, true]
  end

  should 'hide private events from guests' do
    user = create_user('userwithevents').person
    stubs(:user).returns(nil)
    event = fast_create(Event, :profile_id => user.id, :published => false)
    date = event.start_date
    calendar = populate_calendar(date, Environment.default.events)
    assert_includes calendar, [date, false, true]
  end

  should 'hide events from invisible profiles from guests' do
    user = create_user('usernonvisible', {}, {:visible => false}).person
    stubs(:user).returns(nil)
    event = fast_create(Event, :profile_id => user.id)
    date = event.start_date
    calendar = populate_calendar(date, Environment.default.events)
    assert_includes calendar, [date, false, true]
  end

  should 'hide events from private profiles from guests' do
    user = create_user('usernonvisible', {}, {:visible => false}).person
    stubs(:user).returns(nil)
    event = fast_create(Event, :profile_id => user.id)
    date = event.start_date
    calendar = populate_calendar(date, Environment.default.events)
    assert_includes calendar, [date, false, true]
  end

  should 'show private events to owner' do
    user = create_user('userwithevents').person
    stubs(:user).returns(user)
    event = fast_create(Event, :profile_id => user.id, :published => false)
    date = event.start_date
    calendar = populate_calendar(date, Environment.default.events)
    assert_includes calendar, [date, true, true]
  end

  should 'show events from invisible profiles to owner' do
    user = create_user('usernonvisible', {}, {:visible => false}).person
    stubs(:user).returns(user)
    event = fast_create(Event, :profile_id => user.id)
    date = event.start_date
    calendar = populate_calendar(date, Environment.default.events)
    assert_includes calendar, [date, true, true]
  end

  should 'show events from private profiles to owner' do
    user = create_user('usernonvisible', {}, {:visible => false}).person
    stubs(:user).returns(user)
    event = fast_create(Event, :profile_id => user.id)
    date = event.start_date
    calendar = populate_calendar(date, Environment.default.events)
    assert_includes calendar, [date, true, true]
  end

  protected
  include NoosferoTestHelper

end
