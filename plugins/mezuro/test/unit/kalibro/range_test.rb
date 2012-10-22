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

	should 'create a default color for new range' do 
		assert_equal "#e4ca2d", Kalibro::Range.new.mezuro_color
	end
	
	should "convert color from 'ff' to '#'" do
		assert_equal "#ff0000", @range.mezuro_color
	end

	should "convert color from '#' to 'ff' when creating a new range" do
		assert_equal "ffff0000", Kalibro::Range.new({:color => '#ff0000'}).color
	end
	
end
