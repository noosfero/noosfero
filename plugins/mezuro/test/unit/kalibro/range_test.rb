require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/range_fixtures"

class RangeTest < ActiveSupport::TestCase

  def setup
    @hash = RangeFixtures.range_bad_hash
    @range = RangeFixtures.range_bad
  end

  should 'create range from hash' do
    assert_equal @hash[:label], Kalibro::Range.new(@hash).label
  end

  should 'convert range to hash' do
    assert_equal @hash, @range.to_hash
  end

end
