class Kalibro::BaseTool < Kalibro::Model

  attr_accessor :name, :description, :supported_metric

  def self.all_names
    request("BaseTool", :get_base_tool_names)[:base_tool_name].to_a
  end

  def self.find_by_name(base_tool_name)
    new request("BaseTool", :get_base_tool, {:base_tool_name => base_tool_name})[:base_tool]
  end

  def supported_metric=(value)
    @supported_metric = Kalibro::NativeMetric.to_objects_array value
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
