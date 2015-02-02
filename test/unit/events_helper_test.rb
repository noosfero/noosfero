require_relative "../test_helper"

class EventsHelperTest < ActiveSupport::TestCase

  include EventsHelper

  should 'list events' do
    user = create_user('userwithevents').person
    stubs(:user).returns(user)

    expects(:show_date_month).returns('')
    expects(:_).with('Events for %s').returns('').once
    expects(:_).with(' to ').returns('').twice
    expects(:_).with('Place: ').returns('').twice
    expects(:_).with('No events for this month').returns('').never

    event1 = mock;
    event1.expects(:display_to?).with(anything).returns(true).once;
    event1.expects(:start_date).returns(Date.today).once
    event1.expects(:end_date).returns(Date.today + 1.day).twice
    event1.expects(:name).returns('Event 1').once
    event1.expects(:url).returns({}).once
    event1.expects(:address).returns('The Shire').times(3)

    event2 = mock;
    event2.expects(:display_to?).with(anything).returns(true).once
    event2.expects(:start_date).returns(Date.today).once
    event2.expects(:end_date).returns(Date.today + 1.day).twice
    event2.expects(:name).returns('Event 2').once
    event2.expects(:url).returns({}).once
    event2.expects(:address).returns('Valfenda').times(3)

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
