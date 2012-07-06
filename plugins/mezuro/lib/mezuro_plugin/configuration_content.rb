class MezuroPlugin::ConfigurationContent < Article
  validate_on_create :validate_kalibro_configuration_name

  def self.short_description
    'Kalibro configuration'
  end

  def self.description
    'Sets of thresholds to interpret metrics'
  end

  settings_items :description

  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/show_configuration.rhtml'
    end
  end

  def configuration
    Kalibro::Client::ConfigurationClient.configuration(name)
  end
  
  def metric_configurations
    configuration.metric_configurations
  end
  

  after_save :send_configuration_to_service
  after_destroy :remove_configuration_from_service

  private

  def validate_kalibro_configuration_name
    existing = Kalibro::Client::ConfigurationClient.new.configuration_names
    existing.each { |a| a.downcase!}

    if existing.include?(name.downcase)
      errors.add_to_base("Configuration name already exists in Kalibro")
    end
  end

  def send_configuration_to_service
    Kalibro::Client::ConfigurationClient.save(self)
  end

  def remove_configuration_from_service
    Kalibro::Client::ConfigurationClient.remove(name)
  end

end
