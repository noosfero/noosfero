require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/range_fixtures"

class MetricConfigurationTest < ActiveSupport::TestCase

  def setup
    @native_metric_configuration = MetricConfigurationFixtures.amloc_metric_configuration
    @native_metric_configuration_hash = MetricConfigurationFixtures.amloc_metric_configuration_hash
    @compound_metric_configuration = MetricConfigurationFixtures.sc_metric_configuration
    @metric_configuration_without_ranges = MetricConfigurationFixtures.metric_configuration_without_ranges
    @excellent_range = RangeFixtures.range_excellent
    @bad_range = RangeFixtures.range_bad
  end

  should 'create metric configuration from hash' do
    assert_equal @native_metric_configuration_hash[:code], Kalibro::MetricConfiguration.new(@native_metric_configuration_hash).code
  end

  should 'convert metric configuration to hash' do
    assert_equal @native_metric_configuration_hash, @native_metric_configuration.to_hash()
  end

  should 'create appropriate metric type' do
    assert @native_metric_configuration.metric.instance_of?(Kalibro::NativeMetric)
    assert @compound_metric_configuration.metric.instance_of?(Kalibro::CompoundMetric)
  end

  should 'add a range to an empty range list' do
    @metric_configuration_without_ranges.add_range @excellent_range
    assert_equal @metric_configuration_without_ranges.ranges, [@excellent_range]
  end
  
  should 'add a range to an non-empty range list' do
    @metric_configuration_without_ranges.ranges = [@excellent_range]
    @metric_configuration_without_ranges.add_range @bad_range
    assert_equal @metric_configuration_without_ranges.ranges, [@excellent_range, @bad_range]
  end

  should 'save metric configuration' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :save_metric_configuration, {
        :metric_configuration => @native_metric_configuration_hash,
        :configuration_name => @native_metric_configuration.configuration_name
      })
    @native_metric_configuration.save
  end

  should 'get metric configuration by name and configuration name' do
    request_body = {
      :configuration_name => @native_metric_configuration.configuration_name,
      :metric_name => @native_metric_configuration.metric.name
    }
    response_hash = {:metric_configuration => @native_metric_configuration_hash}
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, request_body).returns(response_hash)
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@native_metric_configuration.configuration_name,
                                                                                         @native_metric_configuration.metric.name)
    assert_equal @native_metric_configuration.code, metric_configuration.code
  end

  should 'destroy metric configuration by name' do
    request_body = {
      :configuration_name => @native_metric_configuration.configuration_name,
      :metric_name => @native_metric_configuration.metric.name
    }
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :remove_metric_configuration, request_body)
    @native_metric_configuration.destroy
  end

end
