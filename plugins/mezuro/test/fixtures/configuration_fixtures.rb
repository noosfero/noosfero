require File.dirname(__FILE__) + '/metric_configuration_fixtures'

class ConfigurationFixtures

  def self.configuration
    Kalibro::Configuration.new configuration_hash
  end

  def self.configuration_hash
    {
      :name => 'Sample Configuration',
      :description => 'Kalibro configuration for Java projects.',
      :metric_configuration => [
        MetricConfigurationFixtures.amloc_metric_configuration_hash,
        MetricConfigurationFixtures.sc_metric_configuration_hash
      ]
    }
  end
  
  def self.configuration_content(clone_configuration)
    MezuroPlugin::ConfigurationContent.new({
      :name => 'Sample Configuration',
      :description => 'Kalibro configuration for Java projects.',
      :configuration_to_clone_name => clone_configuration
    })
  end

end
