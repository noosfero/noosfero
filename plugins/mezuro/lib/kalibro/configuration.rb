class Kalibro::Configuration < Kalibro::Model

  attr_accessor :name, :description, :metric_configuration

  def metric_configuration=(value)
    @metric_configuration = Kalibro::MetricConfiguration.to_objects_array value
  end

  def metric_configurations
    if @metric_configuration != nil
      @metric_configuration
    else
      []
    end
  end

  def metric_configurations=(metric_configurations)
    @metric_configuration = metric_configurations
  end

  def self.find_by_name(configuration_name)
    begin
      new request("Configuration", :get_configuration, {:configuration_name => configuration_name})[:configuration]
    rescue Exception => error
      nil
    end
  end

  def self.all_names
    begin
      request("Configuration", :get_configuration_names)[:configuration_name]
    rescue Exception
      []
    end
  end

  def update_attributes(attributes={})
    attributes.each { |field, value| send("#{field}=", value) if self.class.is_valid?(field) }
    save
  end

  def metric_configurations_hash
    self.to_hash[:metric_configuration]
  end
end
