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
    new request("Configuration", :get_configuration, {:configuration_name => configuration_name})[:configuration]
  end

  def self.create(content)
	  attributes = {
	    :name => content.name,
  	  :description => content.description
  	}
  	super attributes
  end

  def self.all_names
    request("Configuration", :get_configuration_names)[:configuration_name]
  end

  def destroy 
    self.class.request("Configuration", :remove_configuration, {:configuration_name => name})
  end
end
