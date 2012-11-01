class Kalibro::Configuration < Kalibro::Model

  attr_accessor :id, :name, :description
  
=begin
  def metric_configuration=(value)
    @metric_configuration = Kalibro::MetricConfiguration.to_objects_array value
  end

  def metric_configurations
    @metric_configuration.nil? ? [] : @metric_configuration
  end

  def metric_configurations=(metric_configurations)
    @metric_configuration = metric_configurations
  end
=end

#  Should be on parent class
#
#  def self.exists?(id)
#    request("Configuration", :configuration_exists, {:configuration_id => id})[:exists]
#  end

  def self.find(id)
    if(exists?(id))
      new request("Configuration", :get_configuration, {:configuration_name => configuration_name})[:configuration]
    else
      nil
    end
  end

  def self.configuration_of(repository_id)
    new request("Configuration", :configuration_of, {:repository_id => repository_id})[:configuration]
  end

  def self.all
    request("Configuration", :all_configuration)[:configuration]
  end


  def update_attributes(attributes={})
    attributes.each { |field, value| send("#{field}=", value) if self.class.is_valid?(field) }
    save
  end

#  def metric_configurations_hash
#    self.to_hash[:metric_configuration]
#  end
end
