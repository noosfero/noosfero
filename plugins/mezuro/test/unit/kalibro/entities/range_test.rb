require "test_helper"
class RangeTest < ActiveSupport::TestCase

  Infinity = 1.0/0.0

  def self.amloc_excellent
    range = Kalibro::Entities::Range.new
    range.beginning = 0.0
    range.end = 7.0
    range.label = 'Excellent'
    range.grade = 10.0
    range.color = 'ff00ff00'
    range
  end

  def self.amloc_bad
    range = Kalibro::Entities::Range.new
    range.beginning = 19.5
    range.end = Infinity
    range.label = 'Bad'
    range.grade = 0.0
    range.color = 'ffff0000'
    range
  end

  def self.amloc_excellent_hash
    {:beginning => 0.0, :end => 7.0, :label => 'Excellent',
      :grade => 10.0, :color => 'ff00ff00'}
  end

  def self.amloc_bad_hash
    {:beginning => 19.5, :end => Infinity, :label => 'Bad',
      :grade => 0.0, :color => 'ffff0000'}
  end

  def setup
    @hash = self.class.amloc_bad_hash
    @range = self.class.amloc_bad
  end

  should 'create range from hash' do
    assert_equal @range, Kalibro::Entities::Range.from_hash(@hash)
  end

  should 'convert range to hash' do
    assert_equal @hash, @range.to_hash
  end

end
