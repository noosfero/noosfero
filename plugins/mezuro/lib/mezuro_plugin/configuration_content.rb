class MezuroPlugin::ConfigurationContent < Article

  def self.short_description
    'Kalibro configuration'
  end

  def self.description
    'Sets of thresholds to interpret metrics'
  end

  settings_items :description, :metrics

  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/show_configuration.rhtml'
    end
  end

  def configuration
    Kalibro::Client::ConfigurationClient.configuration(name)
  end

  after_save :send_configuration_to_service
  after_destroy :remove_configuration_from_service

  private

  def send_configuration_to_service
    Kalibro::Client::ConfigurationClient.save(self)
  end

  def remove_configuration_from_service
    Kalibro::Client::ConfigurationClient.remove(name)
  end

end
