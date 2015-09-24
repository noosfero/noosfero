require File.dirname(__FILE__) + '/../../../../test/test_helper'

class ModelWithDate

  def initialize
    @delivery = DateTime.now
  end

  attr_accessor :delivery

  extend SplitDatetime::SplitMethods
  split_datetime :delivery

end

class SplitDatetimeTest < ActiveSupport::TestCase

  def setup
    @m = ModelWithDate.new
    @m.delivery = (Time.mktime(2011) + 2.hours + 2.minutes + 2.seconds).to_datetime
  end

  should 'return get splitted times' do
    assert_equal @m.delivery_date, '2011-01-01'
    assert_equal @m.delivery_time, '02:02'
  end

  should 'return set splitted times by Date' do
    @m.delivery_date = (Time.mktime(2011, 3, 5) + 3.hours + 3.minutes + 3.seconds).to_datetime
    assert_equal @m.delivery_date, '2011-03-05'
    assert_equal @m.delivery_time, '02:02'
  end

  should 'return set splitted times by Time' do
    @m.delivery_time = (Time.mktime(2011, 3, 5) + 3.hours + 3.minutes + 3.seconds).to_datetime
    assert_equal @m.delivery_date, '2011-01-01'
    assert_equal @m.delivery_time, '03:03'
  end

  should 'return set splitted times by Date String' do
    @m.delivery_date = "2011-11-11"
    assert_equal @m.delivery_date, '2011-11-11'
    assert_equal @m.delivery_time, '02:02'
  end

  should 'return set splitted times by Time String' do
    @m.delivery_time = "15:43"
    assert_equal @m.delivery_date, '2011-01-01'
    assert_equal @m.delivery_time, '15:43'
  end

end

