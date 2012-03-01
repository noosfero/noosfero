class Kalibro::Entities::NativeMetric < Kalibro::Entities::Metric

  attr_accessor :origin, :language

  def languages
    @language
  end

  def languages=(languages)
    @language = languages
  end

  def self.new_with_origin_and_name(origin, name)
    metric = new
    metric.name = name
    metric.origin = origin
    metric
  end

end
