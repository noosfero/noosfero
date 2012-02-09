require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/range_fixtures"

class RangeTest < ActiveSupport::TestCase

  def setup
    @hash = RangeFixtures.amloc_bad_hash
    @range = RangeFixtures.amloc_bad
  end

  should 'create range from hash' do
    assert_equal @range, Kalibro::Entities::Range.from_hash(@hash)
  end

  should 'convert range to hash' do
    assert_equal @hash, @range.to_hash
  end

end
