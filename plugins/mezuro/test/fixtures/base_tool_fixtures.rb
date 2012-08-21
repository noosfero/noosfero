require File.dirname(__FILE__) + '/native_metric_fixtures'

class BaseToolFixtures
    
  def self.base_tool
    Kalibro::BaseTool.new base_tool_hash
  end

  def self.base_tool_hash
    {:name => 'Analizo', :supported_metric => [
        NativeMetricFixtures.total_cof_hash,
        NativeMetricFixtures.amloc_hash]}
  end

end
