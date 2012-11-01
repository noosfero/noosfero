require File.dirname(__FILE__) + '/metric_fixtures'

class BaseToolFixtures
    
  def self.base_tool
    Kalibro::BaseTool.new base_tool_hash
  end

  def self.base_tool_hash 
  {
    :name => 'Analizo', 
    :supported_metric => [
      MetricFixtures.total_cof_hash,
      MetricFixtures.amloc_hash], 
    :collector_class_name => "org.analizo.AnalizoMetricCollector"
  }
  end

end
