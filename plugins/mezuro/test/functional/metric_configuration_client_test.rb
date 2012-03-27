require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"

class MetricConfigurationClientTest < ActiveSupport::TestCase

  def setup
    @client = Kalibro::Client::MetricConfigurationClient.new
  end

  should 'save metric configuration' do
    configuration = MetricConfigurationFixtures.amloc_configuration
    @client.save(configuration, 'Configuration X')
  end

  should 'get metric configuration by name' do
    configuration = MetricConfigurationFixtures.amloc_configuration
    assert_equal configuration, @client.metric_configuration('Configuration X', 'Metric X')
  end

  should 'remove metric configuration by name' do
    @client.remove('Configuration X', 'Metric X')
  end

end