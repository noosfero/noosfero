class Kalibro::Entities::Configuration < Kalibro::Entities::Entity

  attr_accessor :name, :description, :metric_configuration

  def metric_configuration=(value)
    @metric_configuration = to_entity_array(value, Kalibro::Entities::MetricConfiguration)
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

end
