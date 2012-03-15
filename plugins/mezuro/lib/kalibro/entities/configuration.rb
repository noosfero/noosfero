class Kalibro::Entities::Configuration < Kalibro::Entities::Entity

  attr_accessor :name, :description, :metric_configuration

  #FIXME Fix metric_configuration / metric_configurationS names

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

  def create_metric_configuration(metric)
    splitted_metric = metric.split(/:/)
    origin = splitted_metric[0]
    name = splitted_metric[1]
    metric = Kalibro::Entities::NativeMetric.new_with_origin_and_name(origin, name)
    metric.scope = 'CLASS'
    metric.languages = ['JAVA']
    Kalibro::Entities::MetricConfiguration.new_with_metric_and_code(metric, name)
 end

end
