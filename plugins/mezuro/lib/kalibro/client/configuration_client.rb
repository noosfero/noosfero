class Kalibro::Client::ConfigurationClient

  def initialize
    @port = Kalibro::Client::Port.new('Configuration')
  end

  def save(configuration)
    @port.request(:save_configuration, {:configuration => configuration.to_hash})
  end

  def self.save(configuration)
    new.save(configuration)
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

  def self.remove(configuration_name)
    new.remove(configuration_name)
  end
end
