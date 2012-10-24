class MezuroPlugin::ConfigurationContent < Article
  validate_on_create :validate_kalibro_configuration_name

  settings_items :description, :configuration_to_clone_name

  after_save :send_kalibro_configuration_to_service
  after_destroy :remove_kalibro_configuration_from_service

  def self.short_description
    'Kalibro configuration'
  end

  def self.description
    'Sets of thresholds to interpret metrics'
  end

  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/show_configuration.rhtml'
    end
  end

  def kalibro_configuration
    begin
      @kalibro_configuration ||= Kalibro::Configuration.find_by_name(self.name)
    rescue Exception => exception 
      errors.add_to_base(exception.message)
    end
    @kalibro_configuration
  end

  def metric_configurations
    kalibro_configuration.metric_configurations
  end

  def kalibro_configuration_names
    begin
      ["None"] + Kalibro::Configuration.all_names.sort
    rescue Exception => exception
      errors.add_to_base(exception.message)
      ["None"]
    end
  end

  private

  def validate_kalibro_configuration_name
    existing = kalibro_configuration_names.map { |a| a.downcase}

    if existing.include?(name.downcase)
      errors.add_to_base("Configuration name already exists in Kalibro")
    end
  end

  def send_kalibro_configuration_to_service
    if editing_kalibro_configuration?
      kalibro_configuration.update_attributes({:description => description})
    else
      create_kalibro_configuration
    end
  end

  def remove_kalibro_configuration_from_service
    kalibro_configuration.destroy unless kalibro_configuration.nil?
  end

  def create_kalibro_configuration
    attributes = {:name => name, :description => description}
    if cloning_kalibro_configuration?
      attributes[:metric_configuration] = configuration_to_clone.metric_configurations_hash
    end
    Kalibro::Configuration.create attributes
  end
  
  def editing_kalibro_configuration?
    kalibro_configuration.present?
  end
  
  def configuration_to_clone
    @configuration_to_clone ||= find_configuration_to_clone
  end
  
  def find_configuration_to_clone
    (configuration_to_clone_name == "None") ? nil : Kalibro::Configuration.find_by_name(configuration_to_clone_name)
  end
  
  def cloning_kalibro_configuration?
    configuration_to_clone.present?
  end

end
