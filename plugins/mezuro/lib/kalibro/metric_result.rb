class Kalibro::MetricResult < Kalibro::Model

  attr_accessor :metric, :value, :range, :descendent_result, :weight

  def metric=(value)
    if value.kind_of?(Hash)
      compound?(value) ? @metric = to_object(value, Kalibro::CompoundMetric) : @metric = to_object(value, Kalibro::NativeMetric)
    else
      @metric = value
    end
  end
  
  def compound?(metric)
    metric.has_key?(:script)
  end

  def value=(value)
    @value = value.to_f
  end

  def range=(value)
    @range = to_object(value, Kalibro::Range)
  end

  def descendent_result=(value)
    array = value.kind_of?(Array) ? value : [value]
    @descendent_result = array.collect {|element| element.to_f}
  end

  def descendent_results
    @descendent_result
  end

  def descendent_results=(descendent_results)
    @descendent_result = descendent_results
  end

end
