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
    begin
      @configuration ||= Kalibro::Configuration.find_by_name(self.name)
    rescue Exception => error
      errors.add_to_base(error.message)
      nil
    end
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
    if configuration.nil?
      begin
        clone_configuration = Kalibro::Configuration.find_by_name(self.clone_configuration_name)
      rescue Exception => error
        clone_configuration = nil
      end
      Kalibro::Configuration.create(self, clone_configuration)
    else
      configuration.update_attributes({:description => description})
    end
  end

  def remove_configuration_from_service
    begin
      configuration.destroy
    rescue Exception => error
      errors.add_to_base(error.message)
    end
  end

end
