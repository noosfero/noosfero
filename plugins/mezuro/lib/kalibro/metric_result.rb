class Kalibro::MetricResult < Kalibro::Model

  attr_accessor :metric, :value, :range, :descendent_result, :weight

  def metric=(value)
    if value.kind_of?(Hash)
      @metric = native?(value) ? Kalibro::NativeMetric.to_object(value) : Kalibro::CompoundMetric.to_object(value) 
    else
      @metric = value
    end
  end

  def value=(value)
    @value = value.to_f
  end

  def range=(value)
    @range = Kalibro::Range.to_object value
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
  
  private
  
  def native?(value)
    value.has_key?(:origin) ? true : false
  end

end
