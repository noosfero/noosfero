require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/range_fixtures"

class MetricConfigurationTest < ActiveSupport::TestCase

  def setup
    @hash = MetricConfigurationFixtures.amloc_metric_configuration_hash
    @metric_configuration1 = MetricConfigurationFixtures.amloc_metric_configuration
    @metric_configuration2 = MetricConfigurationFixtures.sc_metric_configuration
    @metric_configuration_without_ranges = MetricConfigurationFixtures.metric_configuration_without_ranges
    @range1 = RangeFixtures.range_excellent
    @range2 = RangeFixtures.range_bad
  end

  should 'create metric configuration from hash' do
    assert_equal @hash[:code], Kalibro::MetricConfiguration.new(@hash).code
  end

  should 'convert metric configuration to hash' do
    assert_equal @hash, @metric_configuration1.to_hash
  end

  should 'create appropriate metric type' do
    assert @metric_configuration1.metric.instance_of?(Kalibro::NativeMetric)
    assert @metric_configuration2.metric.instance_of?(Kalibro::CompoundMetric)
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

  should 'save metric configuration' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :save_metric_configuration, {
        :metric_configuration => @metric_configuration1.to_hash,
        :configuration_name => @metric_configuration1.configuration_name
      })
    @metric_configuration1.save
  end

  should 'get metric configuration by name and configuration name' do
    request_body = {
      :configuration_name => @metric_configuration1.configuration_name,
      :metric_name => @metric_configuration1.metric.name
    }
    response_hash = {:metric_configuration => @metric_configuration1.to_hash}
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, request_body).returns(response_hash)
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@metric_configuration1.configuration_name,
                                                                                         @metric_configuration1.metric.name)
    assert_equal @metric_configuration1.code, metric_configuration.code
  end

  should 'destroy metric configuration by name' do
    request_body = {
      :configuration_name => @metric_configuration1.configuration_name,
      :metric_name => @metric_configuration1.metric.name
    }
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :remove_metric_configuration, request_body)
    @metric_configuration1.destroy
  end

end
