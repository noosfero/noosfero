class Kalibro::Entities::BaseTool < Kalibro::Entities::Entity
  
  attr_accessor :name, :description, :supported_metric

  def supported_metric=(value)
    @supported_metric = to_entity_array(value, Kalibro::Entities::NativeMetric)
  end
  
  def supported_metrics
    @supported_metric
  end

  def supported_metrics=(supported_metrics)
    @supported_metric = supported_metrics
  end

end