class Kalibro::Entities::MetricConfiguration < Kalibro::Entities::Entity

  attr_accessor :metric, :code, :weight, :aggregation_form, :range


  def self.new_with_metric_and_code(metric, code)
    configuration = new
    configuration.metric = metric
    configuration.code = code
    configuration.ranges = [new_range]
    configuration
  end

  def self.new_range
    created_range = Kalibro::Entities::Range.new
    created_range.beginning = 0
    created_range.end = 10
    created_range.label = ""
    created_range
  end

  def metric=(value)
    if value.kind_of?(Hash)
      @metric = to_entity(value, Kalibro::Entities::CompoundMetric) if value.has_key?(:script)
      @metric = to_entity(value, Kalibro::Entities::NativeMetric) if value.has_key?(:origin)
    else
      @metric = value
    end
  end

  def range=(value)
    @range = to_entity_array(value, Kalibro::Entities::Range)
  end

  def ranges
    @range
  end

  def ranges=(ranges)
    @range = ranges
  end

end
