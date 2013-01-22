class Kalibro::BaseTool < Kalibro::Model

  attr_accessor :name, :description, :collector_class_name, :supported_metric

  def self.find_by_name(base_tool_name)
    new request(:get_base_tool, {:base_tool_name => base_tool_name})[:base_tool]
  end

  def self.all
    basetools = all_names
    basetools.map{ |name| find_by_name(name) }
  end

  def self.all_names
    request(:all_base_tool_names)[:base_tool_name].to_a
  end

  def supported_metric=(value)
    @supported_metric = Kalibro::Metric.to_objects_array value
  end

  def supported_metrics
    @supported_metric
  end

  def supported_metrics=(supported_metrics)
    @supported_metric = supported_metrics
  end

  def metric(name)
    supported_metrics.find {|metric| metric.name == name}
  end

end
