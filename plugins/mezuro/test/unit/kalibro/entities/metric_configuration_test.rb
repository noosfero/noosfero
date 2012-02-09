require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"

class MetricConfigurationTest < ActiveSupport::TestCase

  def setup
    @hash = MetricConfigurationFixtures.amloc_configuration_hash
    @range = MetricConfigurationFixtures.amloc_configuration
  end

  should 'create metric configuration from hash' do
    assert_equal @range, Kalibro::Entities::MetricConfiguration.from_hash(@hash)
  end

  should 'convert metric configuration to hash' do
    assert_equal @hash, @range.to_hash
  end

  should 'create appropriate metric type' do
    amloc = MetricConfigurationFixtures.amloc_configuration
    sc = MetricConfigurationFixtures.sc_configuration
    assert amloc.metric.instance_of?(Kalibro::Entities::NativeMetric)
    assert sc.metric.instance_of?(Kalibro::Entities::CompoundMetric)
  end

end
