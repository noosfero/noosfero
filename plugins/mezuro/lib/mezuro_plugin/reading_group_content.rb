class MezuroPlugin::ReadingGroupContent < Article
  include ActionView::Helpers::TagHelper

  settings_items :reading_group_id

  before_save :send_reading_group_to_service
  after_destroy :destroy_reading_group_from_service

  def self.short_description
    'Mezuro reading group'
  end

  def self.description
    'Set of thresholds to interpret metric results'
  end

  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/show_reading_group.rhtml'
    end
  end

  def reading_group
    begin
      @reading_group ||= Kalibro::ReadingGroup.find(reading_group_id)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @reading_group
  end

  def readings
    begin
      @readings ||= Kalibro::Reading.readings_of(reading_group_id)
    rescue Exception => error
      errors.add_to_base(error.message)
      @readings = []
    end
    @readings
  end

  def description=(value)
    @description=value
  end
  
  def description
    begin
      @description ||= reading_group.description
    rescue
      @description = ""
    end
    @description
  end

  def readings=(value)
    @readings = value.kind_of?(Array) ? value : [value]
    @readings = @readings.map { |element| to_reading(element) }
  end

  private
  
  def self.to_reading value
    value.kind_of?(Hash) ? Kalibro::Reading.new(value) : value
  end

  def send_reading_group_to_service
    created_reading_group = create_kalibro_reading_group
    self.reading_group_id = created_reading_group.id
  end

  def create_kalibro_reading_group
   Kalibro::ReadingGroup.create(
      :name => name,
      :description => description,
      :id => self.reading_group_id
    )
  end

  def destroy_reading_group_from_service
    reading_group.destroy unless reading_group.nil?
  end

end
