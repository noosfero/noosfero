class Kalibro::MetricConfiguration < Kalibro::Model

  NATIVE_TYPE='native'
  COMPOUND_TYPE='compound'
  
  attr_accessor :metric, :code, :weight, :aggregation_form, :range, :configuration_name

  def metric=(value)
    if value.kind_of?(Hash)
      @metric = to_object(value, Kalibro::CompoundMetric) if value.has_key?(:script)
      @metric = to_object(value, Kalibro::NativeMetric) if value.has_key?(:origin)
    else
      @metric = value
    end
  end

  def weight=(value)
    @weight = value.to_f
  end

  def range=(value)
    @range = to_objects_array(value, Kalibro::Range)
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
    hash = Hash.new
    fields.each do |field|
      if !(field == :configuration_name)
        field_value = send(field)
        hash[field] = convert_to_hash(field_value)
        if field_value.is_a?(Kalibro::Model)
          hash = {:attributes! => {}}.merge(hash)
          hash[:attributes!][field.to_sym] = {
            'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
            'xsi:type' => 'kalibro:' + xml_class_name(field_value)  }
        end
      end
    end
    hash
  end

end
