require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"

class MetricConfigurationClientTest < ActiveSupport::TestCase

  def setup
    @port = mock
    Kalibro::Client::Port.expects(:new).with('MetricConfiguration').returns(@port)
    @client = Kalibro::Client::MetricConfigurationClient.new
  end

  should 'save metric configuration' do
    configuration = MetricConfigurationFixtures.amloc_configuration
    @port.expects(:request).with(:save_metric_configuration, {
        :metric_configuration => configuration.to_hash,
        :configuration_name => 'x'
      })
    @client.save(configuration, 'x')
  end

  should 'get metric configuration by name' do
    configuration = MetricConfigurationFixtures.amloc_configuration
    request_body = {
      :configuration_name => 'configuration.name',
      :metric_name => configuration.metric.name
    }
    response_hash = {:metric_configuration => configuration.to_hash}
    @port.expects(:request).with(:get_metric_configuration, request_body).returns(response_hash)
    assert_equal configuration, @client.metric_configuration('configuration.name', configuration.metric.name)
  end

  should 'remove metric configuration by name' do
    metric_name = 'MetricConfigurationClientTest'
    configuration_name = 'xxxx'
    request_body = {
      :configuration_name => configuration_name,
      :metric_name => metric_name
    }
    @port.expects(:request).with(:remove_metric_configuration, request_body)
    @client.remove(configuration_name, metric_name)
  end

end