class Kalibro::MetricConfigurationSnapshot < Kalibro::Model

  attr_accessor :code, :weight, :aggregation_form, :metric, :base_tool_name, :range

  def metric=(value)
    if value.kind_of?(Hash)
      @metric = Kalibro::Metric.to_object(value)
    else
      @metric = value
    end
  end

  def range=(value)
    @range = Kalibro::RangeSnapshot.to_object value
  end

  def range_snapshot
    range
  end

end
