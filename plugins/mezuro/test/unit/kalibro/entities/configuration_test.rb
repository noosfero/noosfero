require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"

class ConfigurationTest < ActiveSupport::TestCase

  def setup
    @hash = ConfigurationFixtures.kalibro_configuration_hash
    @configuration = ConfigurationFixtures.kalibro_configuration
  end

  should 'create configuration from hash' do
    assert_equal @configuration, Kalibro::Entities::Configuration.from_hash(@hash)
  end

  should 'convert configuration to hash' do
    assert_equal @hash, @configuration.to_hash
  end

  should 'create metric configuration' do
    configuration = Kalibro::Entities::Configuration.new
    configuration.create_metric_configurations(["Analizo:Metric Name"])
    metric_configuration = configuration.metric_configurations[0]
    assert_equal metric_configuration.code, "Metric Name"
    assert_equal metric_configuration.metric.name, "Metric Name"
    assert_equal metric_configuration.metric.origin, "Analizo"
  end

end
