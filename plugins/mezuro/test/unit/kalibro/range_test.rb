require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/range_fixtures"

class RangeTest < ActiveSupport::TestCase

  def setup
    @hash = RangeFixtures.range_hash
    @range = RangeFixtures.range
    @created_range = RangeFixtures.created_range
  end

  should 'create range from hash' do
    assert_equal @hash[:comments], Kalibro::Range.new(@hash).comments
  end

  should 'convert range to hash' do
    assert_equal @hash, @range.to_hash
  end

  should 'get ranges of a metric configuration' do
    metric_configuration_id = 31
    Kalibro::Range.expects(:request).with(:ranges_of, {:metric_configuration_id => metric_configuration_id}).returns({:range => [@hash]})
    assert_equal @hash[:comments], Kalibro::Range.ranges_of(metric_configuration_id).first.comments
  end
  
  should 'return true when range is saved successfully' do
    id_from_kalibro = 1
    metric_configuration_id = 2
    Kalibro::Range.expects(:request).with(:save_range, {:range => @created_range.to_hash, :metric_configuration_id => metric_configuration_id}).returns(:range_id => id_from_kalibro)
    assert @created_range.save(metric_configuration_id)
    assert_equal id_from_kalibro, @created_range.id
  end

  should 'return false when range is not saved successfully' do
    metric_configuration_id = 2
    Kalibro::Range.expects(:request).with(:save_range, {:range => @created_range.to_hash, :metric_configuration_id => metric_configuration_id}).raises(Exception.new)
    assert !(@created_range.save(metric_configuration_id))
    assert_nil @created_range.id
  end

  should 'destroy range by id' do
    Kalibro::Range.expects(:request).with(:delete_range, {:range_id => @range.id})
    @range.destroy
  end

end
