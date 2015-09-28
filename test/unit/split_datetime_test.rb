require 'test_helper'

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
    assert_equal '01/01/2011', @m.delivery_date
    assert_equal '02:02', @m.delivery_time
  end

  should 'return set splitted times by Date' do
    @m.delivery_date = (Time.mktime(2011, 3, 5) + 3.hours + 3.minutes + 3.seconds).to_datetime
    assert_equal '05/03/2011', @m.delivery_date
    assert_equal '02:02', @m.delivery_time
  end

  should 'return set splitted times by Time' do
    @m.delivery_time = (Time.mktime(2011, 3, 5) + 3.hours + 3.minutes + 3.seconds).to_datetime
    assert_equal '01/01/2011', @m.delivery_date
    assert_equal '03:03', @m.delivery_time
  end

  should 'return set splitted times by Date String' do
    @m.delivery_date = "11/11/2011"
    assert_equal '11/11/2011', @m.delivery_date
    assert_equal '02:02', @m.delivery_time
  end

  should 'return set splitted times by Time String' do
    @m.delivery_time = "15:43"
    assert_equal '01/01/2011', @m.delivery_date
    assert_equal '15:43', @m.delivery_time
  end

end

