require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/range_fixtures"

class MetricConfigurationTest < ActiveSupport::TestCase

  def setup
    @hash = MetricConfigurationFixtures.amloc_configuration_hash
    @metric_configuration = MetricConfigurationFixtures.amloc_configuration
    @metric_configuration_without_ranges = MetricConfigurationFixtures.metric_configuration_without_ranges
    @range1 = RangeFixtures.amloc_excellent
    @range2 = RangeFixtures.amloc_bad
  end

  should 'create metric configuration from hash' do
    assert_equal @metric_configuration, Kalibro::Entities::MetricConfiguration.from_hash(@hash)
  end

  should 'convert metric configuration to hash' do
    assert_equal @hash, @metric_configuration.to_hash
  end

  should 'create appropriate metric type' do
    amloc = MetricConfigurationFixtures.amloc_configuration
    sc = MetricConfigurationFixtures.sc_configuration
    assert amloc.metric.instance_of?(Kalibro::Entities::NativeMetric)
    assert sc.metric.instance_of?(Kalibro::Entities::CompoundMetric)
  end

  should 'add a range to an empty range list' do
    @metric_configuration_without_ranges.add_range @range1
    assert_equal @metric_configuration_without_ranges.ranges, [@range1]
  end
  
  should 'add a range to an non-empty range list' do
    @metric_configuration_without_ranges.ranges = [@range1]
    @metric_configuration_without_ranges.add_range @range2
    assert_equal @metric_configuration_without_ranges.ranges, [@range1, @range2]
  end


end
