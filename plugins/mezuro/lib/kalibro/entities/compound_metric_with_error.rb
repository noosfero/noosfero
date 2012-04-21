class Kalibro::Entities::CompoundMetricWithError < Kalibro::Entities::Entity
  
  attr_accessor :metric, :error

  def metric=(value)
    @metric = to_entity(value, Kalibro::Entities::CompoundMetric)
  end
  
  def error=(value)
    @error = to_entity(value, Kalibro::Entities::Error)
  end

end