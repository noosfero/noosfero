require File.dirname(__FILE__) + '/../test_helper'

class DatesHelperTest < Test::Unit::TestCase

  include DatesHelper

  should 'generate period with two dates' do
    date1 = mock
    expects(:show_date).with(date1).returns('XXX')
    date2 = mock
    expects(:show_date).with(date2).returns('YYY')
    expects(:_).with('from %s to %s').returns('from %s to %s')
    assert_equal 'from XXX to YYY', show_period(date1, date2)
  end

  should 'generate period with two equal dates' do
    date1 = mock
    expects(:show_date).with(date1).returns('XXX')
    assert_equal 'XXX', show_period(date1, date1)
  end

  should 'generate period with one date only' do
    date1 = mock
    expects(:show_date).with(date1).returns('XXX')
    assert_equal 'XXX', show_period(date1)
  end

  should 'show day of week' do
    expects(:_).with("Sunday").returns("Domingo")
    date = mock
    date.expects(:wday).returns(0)
    assert_equal "Domingo", show_day_of_week(date)
  end

  should 'show month' do
    expects(:_).with('January').returns('January')
    expects(:_).with('%{month} %{year}').returns('%{month} %{year}')
    assert_equal 'January 2008', show_month(2008, 1)
  end

  should 'provide link to previous month' do
    expects(:link_to).with('&larr; January 2008', { :year => 2008, :month => 1})
    link_to_previous_month('2008', '2')
  end

  should 'support last year in link to previous month' do
    expects(:link_to).with('&larr; December 2007', { :year => 2007, :month => 12})
    link_to_previous_month('2008', '1')
  end

  should 'provide link to next month' do
    expects(:link_to).with('March 2008 &rarr;', { :year => 2008, :month => 3})
    link_to_next_month('2008', '2')
  end

  should 'support next year in link to next month' do
    expects(:link_to).with('January 2009 &rarr;', { :year => 2009, :month => 1})
    link_to_next_month('2008', '12')
  end

  should 'get current date when year and month are not informed for next month' do
    Date.expects(:today).returns(Date.new(2008,1,1))
    expects(:link_to).with('February 2008 &rarr;', { :year => 2008, :month => 2})
    link_to_next_month(nil, nil)
  end

  should 'get current date when year and month are not informed for previous month' do
    Date.expects(:today).returns(Date.new(2008,1,1))
    expects(:link_to).with('&larr; December 2007', { :year => 2007, :month => 12})
    link_to_previous_month(nil, nil)
  end

end
