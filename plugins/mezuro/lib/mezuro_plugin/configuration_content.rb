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
    begin
      configuration = Kalibro::Configuration.find_by_name(self.name)
      configuration.description = self.description
      configuration
    rescue Exception
      Kalibro::Configuration.new({
        :name => self.name,
        :description => self.description
      })
    end
  end
  
  def metric_configurations
    configuration.metric_configurations
  end
  

  after_save :send_configuration_to_service
  after_destroy :remove_configuration_from_service

  private

  def validate_kalibro_configuration_name
    existing = Kalibro::Configuration.all_names
    existing.each { |a| a.downcase!}

    if existing.include?(name.downcase)
      errors.add_to_base("Configuration name already exists in Kalibro")
    end
  end

  def send_configuration_to_service
    configuration.save
  end

  def remove_configuration_from_service
    configuration.destroy
  end

end
