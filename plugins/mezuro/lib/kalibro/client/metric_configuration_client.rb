class Kalibro::Client::MetricConfigurationClient

  def initialize
    @port = Kalibro::Client::Port.new('MetricConfiguration')
  end

  def save(metric_configuration, configuration_name)
    @port.request(:save_metric_configuration, {
        :metric_configuration => metric_configuration.to_hash,
        :configuration_name => configuration_name})
  end

  def metric_configuration(configuration_name, metric_name)
    hash = @port.request(:get_metric_configuration, {
        :configuration_name => configuration_name,
        :metric_name => metric_name
      })[:metric_configuration]
    Kalibro::Entities::MetricConfiguration.from_hash(hash)
  end

  def remove (configuration_name, metric_name)
    @port.request(:remove_metric_configuration, {
        :configuration_name => configuration_name,
        :metric_name=> metric_name
      })
  end

end