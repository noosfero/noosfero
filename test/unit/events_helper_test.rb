require File.dirname(__FILE__) + '/../test_helper'

class EventsHelperTest < ActiveSupport::TestCase

  include EventsHelper

  should 'list events' do
    expects(:show_date).returns('')
    expects(:_).with('Events for %s').returns('')
    event1 = mock; event1.expects(:public?).returns(true); event1.expects(:name).returns('Event 1'); event1.expects(:url).returns({})
    event2 = mock; event2.expects(:public?).returns(true); event2.expects(:name).returns('Event 2'); event2.expects(:url).returns({})
    result = list_events('', [event1, event2])
    assert_match /Event 1/, result
    assert_match /Event 2/, result
  end

  protected

  def content_tag(tag, text, options = {})
    "<#{tag}>#{text}</#{tag}>"
  end
  def icon_for_article(article)
    ''
  end
  def image_tag(arg)
    arg
  end
  def link_to(text, url, options = {})
    "<a href='#{url.to_s}'>#{text}</a>"
  end

end
