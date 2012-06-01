require File.dirname(__FILE__) + '/metric_configuration_fixtures'

class ConfigurationFixtures

  def self.kalibro_configuration
    configuration = Kalibro::Entities::Configuration.new
    configuration.name = 'Kalibro for Java'
    configuration.description = 'Kalibro configuration for Java projects.'
    configuration.metric_configurations = [
      MetricConfigurationFixtures.amloc_configuration,
      MetricConfigurationFixtures.sc_configuration]
    configuration
  end

  def self.kalibro_configuration_hash
    {:name => 'Kalibro for Java', :description => 'Kalibro configuration for Java projects.',
      :metric_configuration => [
        MetricConfigurationFixtures.amloc_configuration_hash,
        MetricConfigurationFixtures.sc_configuration_hash]}
  end
    
end
