class Kalibro::DateMetricResult < Kalibro::Model
  
  attr_accessor :date, :metric_result

  def date=(value)
    @date = value.is_a?(String) ? DateTime.parse(value) : value
  end

  def metric_result=(value)
    @metric_result = Kalibro::MetricResult.to_object value
  end

  def result
    @metric_result.value
  end
end
