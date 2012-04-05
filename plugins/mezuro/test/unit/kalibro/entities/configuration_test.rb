require "test_helper"
class ConfigurationTest < ActiveSupport::TestCase

  def self.kalibro_configuration
    amloc_configuration = MetricConfigurationTest.amloc_configuration
    sc_configuration = MetricConfigurationTest.sc_configuration
    configuration = Kalibro::Entities::Configuration.new
    configuration.name = 'Kalibro for Java'
    configuration.description = 'Kalibro configuration for Java projects.'
    configuration.metric_configurations = [amloc_configuration, sc_configuration]
    configuration
  end

  def self.kalibro_configuration_hash
    amloc_hash = MetricConfigurationTest.amloc_configuration_hash
    sc_hash = MetricConfigurationTest.sc_configuration_hash
    {:name => 'Kalibro for Java',
      :description => 'Kalibro configuration for Java projects.',
      :metric_configuration => [amloc_hash, sc_hash]}
  end

  def setup
    @hash = self.class.kalibro_configuration_hash
    @configuration = self.class.kalibro_configuration
  end

  should 'create configuration from hash' do
    assert_equal @configuration, Kalibro::Entities::Configuration.from_hash(@hash)
  end

  should 'convert configuration to hash' do
    assert_equal @hash, @configuration.to_hash
  end

end