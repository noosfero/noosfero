class ConfigurationContentFixtures

  def self.configuration_content
    MezuroPlugin::ConfigurationContent.new configuration_content_hash
  end
  
  def self.created_configuration_content
    MezuroPlugin::ConfigurationContent.new( {
      :name => 'Sample Configuration',
      :description => 'Kalibro configuration for Java projects.',
      :configuration_id => nil
    } )
  end

  def self.configuration_content_hash
    {
      :name => 'Sample Configuration',
      :description => 'Kalibro configuration for Java projects.',
      :configuration_id => "42"
    }
  end

end
