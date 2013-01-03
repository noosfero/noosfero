require File.dirname(__FILE__) + '/metric_configuration_fixtures'

class ConfigurationFixtures

  def self.configuration
    Kalibro::Configuration.new configuration_hash
  end

  def self.created_configuration
    Kalibro::Configuration.new({
      :name => 'Created Sample Configuration',
      :description => 'Kalibro configuration for Java projects.'
    })
  end

  def self.configuration_hash
    {
      :id => "42",
      :name => 'Sample Configuration',
      :description => 'Kalibro configuration for Java projects.'
    }
  end
  
  def self.all
    [configuration]
  end

end
