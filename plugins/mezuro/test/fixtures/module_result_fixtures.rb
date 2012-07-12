require File.dirname(__FILE__) + '/module_fixtures'
require File.dirname(__FILE__) + '/metric_result_fixtures'
require File.dirname(__FILE__) + '/compound_metric_with_error_fixtures'

class ModuleResultFixtures

  def self.module_result
    Kalibro::ModuleResult.new( module_result_hash )
  end

  def self.module_result_hash
    {
      :module => ModuleFixtures.qt_calculator_hash,
      :date => '2011-10-20T18:26:43.151+00:00',
      :grade => 10.0,
      :metric_result => [
        MetricResultFixtures.amloc_result_hash,
        MetricResultFixtures.sc_result_hash],
      :compound_metric_with_error => [CompoundMetricWithErrorFixtures.create_hash]
    }
  end

end
