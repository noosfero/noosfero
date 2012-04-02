class Kalibro::Entities::MetricResult < Kalibro::Entities::Entity

  attr_accessor :metric, :value, :range, :descendent_result, :weight

  def metric=(value)
    if value.kind_of?(Hash)
      if value.has_key?(:script)
        @metric = to_entity(value, Kalibro::Entities::CompoundMetric)
      else
        @metric = to_entity(value, Kalibro::Entities::NativeMetric)
      end
    else
      @metric = value
    end
  end

  def value=(value)
    @value = value.to_f
  end

  def range=(value)
    @range = to_entity(value, Kalibro::Entities::Range)
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
