class MezuroPlugin::ConfigurationContent < Article
  validate_on_create :validate_kalibro_configuration_name

  def self.short_description
    'Kalibro configuration'
  end

  def self.description
    'Sets of thresholds to interpret metrics'
  end

  settings_items :description, :clone_configuration_name

  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/show_configuration.rhtml'
    end
  end

  def configuration
    @configuration ||= Kalibro::Configuration.find_by_name(self.name)
    if @configuration.nil? 
      errors.add_to_base("Kalibro Configuration not found")
    end
    @configuration
  end

  def metric_configurations
    configuration.metric_configurations
  end

  def configuration_names
    ["None"] + Kalibro::Configuration.all_names.sort
  end

  after_save :send_configuration_to_service
  after_destroy :remove_configuration_from_service

  private

  def validate_kalibro_configuration_name
    existing = configuration_names.map { |a| a.downcase}

    if existing.include?(name.downcase)
      errors.add_to_base("Configuration name already exists in Kalibro")
    end
  end

  def send_configuration_to_service
    if editing_configuration?
      configuration.update_attributes({:description => description})
    else
      create_kalibro_configuration
    end
  end

  def remove_configuration_from_service
    configuration.destroy
  end

  def create_kalibro_configuration
    attributes = {:name => name, :description => description}
    if cloning_configuration?
      attributes[:metric_configuration] = configuration_to_clone.metric_configurations_hash
    end
    Kalibro::Configuration.create attributes
  end
  
  def editing_configuration?
    !configuration.nil?
  end
  
  def configuration_to_clone
    @configuration_to_clone ||= Kalibro::Configuration.find_by_name(self.clone_configuration_name)
  end
  
  def cloning_configuration?
    configuration_to_clone.nil?
  end

end
