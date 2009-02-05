require File.dirname(__FILE__) + '/../test_helper'

class DatesHelperTest < Test::Unit::TestCase

  include DatesHelper

  should 'translate month names' do
    expects(:_).with('January').returns('Janeiro')
    assert_equal "Janeiro", month_name(1)
  end

  should 'display date with translation' do
    expects(:_).with('%{month} %{day}, %{year}').returns('%{day} de %{month} de %{year}')
    expects(:_).with('January').returns('Janeiro')
    assert_equal '11 de Janeiro de 2008', show_date(Date.new(2008, 1, 11))
  end

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

  should 'fallback to current year/month in show_month' do
    Date.expects(:today).returns(Date.new(2008,11,1)).at_least_once

    expects(:_).with('November').returns('November').at_least_once
    expects(:_).with('%{month} %{year}').returns('%{month} %{year}').at_least_once
    assert_equal 'November 2008', show_month(nil, nil)
    assert_equal 'November 2008', show_month('', '')
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

  should 'provide an intertionalized date selector pass month names' do

    expects(:gettext).with('January').returns('January')
    expects(:gettext).with('February').returns('February')
    expects(:gettext).with('March').returns('March')
    expects(:gettext).with('April').returns('April')
    expects(:gettext).with('May').returns('May')
    expects(:gettext).with('June').returns('June')
    expects(:gettext).with('July').returns('July')
    expects(:gettext).with('August').returns('August')
    expects(:gettext).with('September').returns('September')
    expects(:gettext).with('October').returns('October')
    expects(:gettext).with('November').returns('November')
    expects(:gettext).with('December').returns('December')

    expects(:date_select).with(:object, :method, { :include_blank => true, :order => [:month, :day, :year], :use_month_names => ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']}).returns("KKKKKKKK")

    assert_equal 'KKKKKKKK', pick_date(:object, :method)
  end

  should 'order date in english like month day year' do
    locale = mock
    locale.expects(:to_s).returns('en')
    GetText.stubs(:locale).returns(locale)
    expects(:date_select).with(:object, :method, { :include_blank => true, :order => [:month, :day, :year], :use_month_names => ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']}).returns("KKKKKKKK")

    assert_equal 'KKKKKKKK', pick_date(:object, :method)
  end

  should 'order date in other languages like day month year' do
    locale = mock
    locale.expects(:to_s).returns('pt_BR')
    GetText.stubs(:locale).returns(locale)
    expects(:date_select).with(:object, :method, { :include_blank => true, :order => [:day, :month, :year], :use_month_names => ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']}).returns("KKKKKKKK")

    assert_equal 'KKKKKKKK', pick_date(:object, :method)
  end

end
