class Kalibro::MetricConfigurationSnapshot < Kalibro::Model

  attr_accessor :code, :weight, :aggregation_form, :metric, :base_tool_name, :range

  def weight=(value)
    @weight = value.to_f
  end

  def metric=(value)
    if value.kind_of?(Hash)
      @metric = Kalibro::Metric.to_object(value)
    else
      @metric = value
    end
  end

  def range=(value)
    value.to_a
    @range = []

    value.each do |range_snapshot|
      @range << Kalibro::RangeSnapshot.to_object(range_snapshot)
    end

  end

  def range_snapshot
    range
  end

  def to_hash
    hash = super
    hash[:attributes!][:range] = {'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
                    'xsi:type' => 'kalibro:rangeSnapshotXml'  }
    hash
  end

end
