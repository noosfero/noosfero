require 'test_helper'

class EventBlockHelperTest < ActionView::TestCase
  include EventPlugin::EventBlockHelper

  should 'write formatable data in html' do
    html = '<span class="week-day">Tue</span>'+
           '<span class="month">Sep</span>'+
           '<span class="day">27</span>'+
           '<span class="year">1983</span>'

    assert_equal html, date_to_html(Date.new 1983, 9, 27)
  end

  should 'say human left time for an event' do
    assert_match /Tomorrow/, human_time_left(1)
    assert_match /5 days left/, human_time_left(5)
    assert_match /30 days left/, human_time_left(30)
    assert_match /2 months left/, human_time_left(60)
    assert_match /3 months left/, human_time_left(85)
  end

  should 'say human past time for an event' do
    assert_match /Yesterday/, human_time_left(-1)
    assert_match /5 days ago/, human_time_left(-5)
    assert_match /30 days ago/, human_time_left(-30)
    assert_match /2 months ago/, human_time_left(-60)
    assert_match /3 months ago/, human_time_left(-85)
  end

  should 'say human present time for an event' do
    assert_match /Today/, human_time_left(0)
  end
end
