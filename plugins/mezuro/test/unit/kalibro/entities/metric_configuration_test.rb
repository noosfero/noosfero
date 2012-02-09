require "test_helper"
class MetricConfigurationTest < ActiveSupport::TestCase

  def self.amloc_configuration
    range1 = RangeTest.amloc_excellent
    range2 = RangeTest.amloc_bad
    amloc = Kalibro::Entities::MetricConfiguration.new
    amloc.metric = NativeMetricTest.amloc
    amloc.code = 'amloc'
    amloc.weight = 1.0
    amloc.aggregation_form = 'AVERAGE'
    amloc.ranges = [range1, range2]
    amloc
  end

  def self.sc_configuration
    sc = Kalibro::Entities::MetricConfiguration.new
    sc.metric = CompoundMetricTest.sc
    sc.code = 'sc'
    sc.weight = 1.0
    sc.aggregation_form = 'AVERAGE'
    sc
  end

  def self.amloc_configuration_hash
    range1 = RangeTest.amloc_excellent_hash
    range2 = RangeTest.amloc_bad_hash
    {:metric => NativeMetricTest.amloc_hash,
      :code => 'amloc', :weight => 1.0, :aggregation_form => 'AVERAGE',
      :range => [range1, range2]}
  end

  def self.sc_configuration_hash
    {:metric => CompoundMetricTest.sc_hash,
      :code => 'sc', :weight => 1.0, :aggregation_form => 'AVERAGE'}
  end

  def setup
    @hash = self.class.amloc_configuration_hash
    @range = self.class.amloc_configuration
  end

  should 'create metric configuration from hash' do
    assert_equal @range, Kalibro::Entities::MetricConfiguration.from_hash(@hash)
  end

  should 'convert metric configuration to hash' do
    assert_equal @hash, @range.to_hash
  end

  should 'create appropriate metric type' do
    assert self.class.amloc_configuration.metric.instance_of?(Kalibro::Entities::NativeMetric)
    assert self.class.sc_configuration.metric.instance_of?(Kalibro::Entities::CompoundMetric)
  end

end
