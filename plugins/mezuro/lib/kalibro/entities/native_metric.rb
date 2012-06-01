class Kalibro::Entities::NativeMetric < Kalibro::Entities::Metric

  attr_accessor :origin, :language

  def languages
    @language
  end

  def languages=(languages)
    @language = languages
  end

  def language=(value)
    @language = to_entity_array(value)
  end

end
