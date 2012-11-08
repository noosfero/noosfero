class Kalibro::MetricConfiguration < Kalibro::Model

  attr_accessor :id, :code, :metric, :base_tool_name, :weight, :aggregation_form, :reading_group_id, :configuration_id

  def metric=(value)
    @metric = Kalibro::Metric.to_object(value)
  end

  def weight=(value)
    @weight = value.to_f
  end

  def update_attributes(attributes={})
    attributes.each { |field, value| send("#{field}=", value) if self.class.is_valid?(field) }
    save
  end

  def to_hash
    super :except => [:configuration_id]
  end

  def self.metric_configurations_of(configuration_id)
    hash = request(:metric_configurations_of, {:configuration_id => configuration_id})
    hash[:metric_configuration].to_a.map { |metric_configuration| new metric_configuration }
  end

  private
  
  def save_params
    {:metric_configuration => self.to_hash, :configuration_id => self.configuration_id}
  end
  
end
