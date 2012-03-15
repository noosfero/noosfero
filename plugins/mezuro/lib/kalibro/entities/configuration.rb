class Kalibro::Entities::Configuration < Kalibro::Entities::Entity

  attr_accessor :name, :description, :metric_configuration

  def metric_configuration=(value)
    @metric_configuration = to_entity_array(value, Kalibro::Entities::MetricConfiguration)
  end

  def metric_configurations
    @metric_configuration
  end

  def metric_configurations=(metric_configurations)
    @metric_configuration = metric_configurations
  end

  def create_metric_configurations(metrics)
    @metric_configuration = []
    metrics.each do |metric|
      @metric_configuration << create_metric_configuration(metric)
    end
  end

end
