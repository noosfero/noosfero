require_relative '../test_helper'

class EventsBlockTest < ActiveSupport::TestCase
  should 'describe itself' do
    assert_not_equal Block.description, EventsPlugin::EventsBlock.description
  end

  should 'is editable' do
    block = EventsPlugin::EventsBlock.new
    assert block.editable?
  end

  should 'return events' do
    profile = create(Profile, name: 'Test')
    event1 = create(Event, profile: profile)
    event2 = create(Event, profile: profile)
    event3 = create(Event, profile: create(Profile, name: 'Other'))

    block = EventsPlugin::EventsBlock.new
    block.stubs(:owner).returns(profile)

    assert_equal [event1, event2].map(&:id), block.events.map(&:id)
  end
end

require 'boxes_helper'

class EventsBlockViewTest < ActionView::TestCase
  include BoxesHelper

  should 'return events in api_content' do
    profile = create(Profile, name: 'Test')
    event1 = create(Event, profile: profile)
    event2 = create(Event, profile: profile)
    event3 = create(Event, profile: create(Profile, name: 'Other'))

    block = EventsPlugin::EventsBlock.new
    block.stubs(:owner).returns(profile)

    assert_equal [event1.id, event2.id], block.api_content[:events].map{ |e| e[:id] }
  end
end
