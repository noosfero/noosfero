class MezuroPlugin::MetricConfigurationContent < Article

  def self.short_description
    'Kalibro Configurated Metric'
  end

  def self.description
    'Sets of thresholds to interpret a metric'
  end

  settings_items :description, :code, :weight, :scope, :aggregation_form, :range

  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/show_configuration.rhtml'
    end
  end

  def metric_configuration
    Kalibro::Client::MetricConfigurationClient.metric_configuration(name)
  end

  after_save :send_metric_configuration_to_service
  after_destroy :remove_metric_configuration_from_service

  private

  def send_metric_configuration_to_service
    Kalibro::Client::MetricConfigurationClient.save(self)
  end

  def remove_metric_configuration_from_service
    Kalibro::Client::MetricConfigurationClient.remove(name)
  end

end
