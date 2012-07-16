class Kalibro::CompoundMetricWithError < Kalibro::Model
  
  attr_accessor :metric, :error

  def metric=(value)
    @metric = Kalibro::CompoundMetric.to_object value
  end
  
  def error=(value)
    @error = Kalibro::Error.to_object value
  end

end
