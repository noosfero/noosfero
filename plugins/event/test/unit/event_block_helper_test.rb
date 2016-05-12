require 'test_helper'

class EventBlockHelperTest < ActionView::TestCase
  include EventBlockHelper

  should 'write formatable data in html' do
    html = '<span class="week-day">Tue</span>'+
           '<span class="month">Sep</span>'+
           '<span class="day">27</span>'+
           '<span class="year">1983</span>'

    assert_equal html, date_to_html(Date.new 1983, 9, 27)
  end
end
