class MezuroPlugin::ConfigurationContent < Article

  def self.short_description
    'Kalibro configuration'
  end

  def self.description
    'Kalibro configuration for some project'
  end

  settings_items :description

  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/show_configuration.rhtml'
    end
  end

  def configuration
    Kalibro::Client::ConfigurationClient.new.configuration(title)
  end

  after_save :send_configuration_to_service
  after_destroy :remove_configuration_from_service

  private

  def send_configuration_to_service
    Kalibro::Client::ConfigurationClient.save(create_configuration)
  end

  def remove_configuration_from_service
    Kalibro::Client::ConfigurationClient.remove(title)
  end

  def create_configuration
    configuration = Kalibro::Entities::Configuration.new
    configuration.name = title
    configuration.description = description
    configuration
  end

end
