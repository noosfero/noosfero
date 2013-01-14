require File.dirname(__FILE__) + '/metric_configuration_fixtures'

class ConfigurationFixtures

  def self.configuration
    Kalibro::Configuration.new configuration_hash
  end

  def self.created_configuration
    Kalibro::Configuration.new({
      :name => 'Sample Configuration',
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
  
  def self.configuration_content(clone_configuration)
    MezuroPlugin::ConfigurationContent.new({
      :name => 'Sample Configuration',
      :description => 'Kalibro configuration for Java projects.',
      :configuration_to_clone_name => clone_configuration
    })
  end

def self.all
  [configuration]
end

end
