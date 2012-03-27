require "test_helper"
require File.dirname(__FILE__) + '/fake_port'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"

class MetricConfigurationClientTest < ActiveSupport::TestCase

  def setup
    fake_port = FakePort.new('MetricConfiguration')
    Kalibro::Client::Port.expects(:new).with('MetricConfiguration').returns(fake_port)
    @client = Kalibro::Client::MetricConfigurationClient.new
  end

  should 'save metric configuration' do
    configuration = MetricConfigurationFixtures.amloc_configuration
    @client.save(configuration, 'Configuration X')
  end

  should 'get metric configuration by name' do
    configuration = @client.metric_configuration('C', 'native')
    assert_equal 'metricOfC', configuration.code
    assert_equal 1.0, configuration.weight
    assert_equal 'AVERAGE', configuration.aggregation_form
    assert_equal 1, configuration.ranges.size

    range = configuration.ranges[0]
    assert_equal -1.0/0.0, range.beginning
    assert_equal 1.0/0.0, range.end

    metric = configuration.metric
    puts metric
    assert metric.is_a?(Kalibro::Entities::NativeMetric)
    assert_equal 'Metric of C', metric.name
    assert_equal 'METHOD', metric.scope
    assert_equal ['JAVA'], metric.languages
    assert_equal 'Metric of C description', metric.description
  end

  should 'remove metric configuration by name' do
    @client.remove('Configuration X', 'Metric X')
  end

end