class Kalibro::Client::ConfigurationClient

  def self.save(configuration_content)
    configuration = Kalibro::Entities::Configuration.new
    configuration.name = configuration_content.name
    configuration.description = configuration_content.description
    configuration.create_metric_configurations(configuration_content.metrics)
    new.save(configuration)
  end

  def self.remove(configuration_name)
    client = new
    client.remove(configuration_name) if client.configuration_names.include? configuration_name
  end

  def initialize
    @port = Kalibro::Client::Port.new('Configuration')
  end

  def save(configuration)
    @port.request(:save_configuration, {:configuration => configuration.to_hash})
  end

  def configuration_names
    @port.request(:get_configuration_names)[:configuration_name].to_a
  end

  def configuration(name)
    hash = @port.request(:get_configuration, {:configuration_name => name})[:configuration]
    Kalibro::Entities::Configuration.from_hash(hash)
  end

  def remove(configuration_name)
    @port.request(:remove_configuration, {:configuration_name => configuration_name})
  end

end
