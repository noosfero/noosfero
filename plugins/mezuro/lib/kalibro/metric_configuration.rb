class Kalibro::MetricConfiguration < Kalibro::Model

  NATIVE_TYPE='native'
  COMPOUND_TYPE='compound'
  
  attr_accessor :metric, :code, :weight, :aggregation_form, :range, :configuration_name

  def metric=(value)
    if value.kind_of?(Hash)
      @metric = native?(value) ? Kalibro::NativeMetric.to_object(value) : Kalibro::CompoundMetric.to_object(value) 
    else
      @metric = value
    end
  end

  def weight=(value)
    @weight = value.to_f
  end

  def range=(value)
    @range = Kalibro::Range.to_objects_array value
  end

  def add_range(new_range)
    @range = [] if @range.nil?
    @range << new_range
  end

  def ranges
    @range
  end

  def ranges=(ranges)
    @range = ranges
  end

  def update_attributes(attributes={})
    attributes.each { |field, value| send("#{field}=", value) if self.class.is_valid?(field) }
    save
  end

  def self.find_by_configuration_name_and_metric_name(configuration_name, metric_name)
    metric_configuration = new request("MetricConfiguration", :get_metric_configuration, {
        :configuration_name => configuration_name,
        :metric_name => metric_name
      })[:metric_configuration]
    metric_configuration.configuration_name = configuration_name
    metric_configuration
  end

  def save
    begin
      self.class.request("MetricConfiguration", :save_metric_configuration, {
        :metric_configuration => to_hash,
        :configuration_name => configuration_name})
      true
    rescue Exception => error
      false
    end
  end

  def destroy
    self.class.request("MetricConfiguration", :remove_metric_configuration, {
        :configuration_name => configuration_name,
        :metric_name=> metric.name
      })
  end
  
  def to_hash
    super :except => [:configuration_name]
  end

  private
  
  def native?(value)
    value.has_key?(:origin) ? true : false
  end

end
