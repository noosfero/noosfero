require File.dirname(__FILE__) + '/native_metric_fixtures'

class BaseToolFixtures
    
  def self.analizo
    base_tool = Kalibro::Entities::BaseTool.new
    base_tool.name = 'Analizo'
    base_tool.supported_metrics = [
      NativeMetricFixtures.total_cof,
      NativeMetricFixtures.amloc]
    base_tool
  end

  def self.analizo_hash
    {:name => 'Analizo', :supported_metric => [
        NativeMetricFixtures.total_cof_hash,
        NativeMetricFixtures.amloc_hash]}
  end

end
