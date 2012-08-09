class Kalibro::NativeMetric < Kalibro::Metric

  attr_accessor :origin, :language

  def languages
    @language
  end

  def languages=(languages)
    @language = languages
  end

  def language=(value)
    @language = Kalibro::Model.to_objects_array value
  end

end
