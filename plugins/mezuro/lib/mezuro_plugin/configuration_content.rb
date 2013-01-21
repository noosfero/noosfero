class MezuroPlugin::ConfigurationContent < Article
  validate_on_create :validate_configuration_name

  settings_items :configuration_id

  before_save :send_configuration_to_service
  after_destroy :remove_configuration_from_service

  def self.short_description
    'Mezuro configuration'
  end

  def self.description
    'Set of metric configurations to interpret a Kalibro project'
  end

  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/show_configuration.rhtml'
    end
  end

  def kalibro_configuration   #Can't be just "configuration", method name exists somewhere in noosfero
    begin
      @configuration ||= Kalibro::Configuration.find(self.configuration_id)
    rescue Exception => exception 
      errors.add_to_base(exception.message)
    end
    @configuration
  end

  def configuration_names_and_ids
    all_names_and_ids = {}
    begin
      all_configurations = Kalibro::Configuration.all
      if(!all_configurations.empty?)
        all_configurations.each do |configuration| 
            all_names_and_ids[configuration.id] = configuration.name
        end
      end
    rescue Exception => exception
      errors.add_to_base(exception.message)
    end
    all_names_and_ids[-1] = "None"
    all_names_and_ids
  end

  def description=(value)
    @description=value
  end
  
  def description
    begin
      @description ||= kalibro_configuration.description
    rescue
      @description = ""
    end
    @description
  end
  
  def metric_configurations
    begin
      @metric_configurations ||= Kalibro::MetricConfiguration.metric_configurations_of(configuration_id)
    rescue Exception => error
      errors.add_to_base(error.message)
      @metric_configurations = []
    end
    @metric_configurations
  end
  
  def metric_configurations=(value)
    @metric_configurations = value.kind_of?(Array) ? value : [value]
    @metric_configurations = @metric_configurations.map { |element| to_metric_configuration(element) }
  end

  private

  def self.to_metric_configuration value
    value.kind_of?(Hash) ? Kalibro::MetricConfiguration.new(value) : value
  end

  def validate_configuration_name
    existing = configuration_names_and_ids.values.map { |a| a.downcase}

    if existing.include?(name.downcase)
      errors.add_to_base("Configuration name already exists in Kalibro")
    end
  end

  def send_configuration_to_service
    attributes = {:id => configuration_id, :name => name, :description => description}
#    if cloning_configuration?
#      attributes[:metric_configuration] = configuration_to_clone.metric_configurations_hash
#    end
    created_configuration = Kalibro::Configuration.create attributes
    self.configuration_id = created_configuration.id
  end

  def remove_configuration_from_service
    puts "aqui tem #{@configuration.inspect}"
    kalibro_configuration.destroy unless kalibro_configuration.nil?
  end

=begin
  def configuration_to_clone
    @configuration_to_clone ||= find_configuration_to_clone
  end
  
  def find_configuration_to_clone
    (configuration_to_clone_name == "None") ? nil : Kalibro::Configuration.find_by_name(configuration_to_clone_name)
  end
  
  def cloning_configuration?
    configuration_to_clone.present?
  end
=end

end
