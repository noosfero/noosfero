require File.dirname(__FILE__) + '/compound_metric_fixtures'
require File.dirname(__FILE__) + '/native_metric_fixtures'
require File.dirname(__FILE__) + '/range_fixtures'

class MetricResultFixtures

  def self.amloc_result
    result = Kalibro::Entities::MetricResult.new
    result.metric = NativeMetricFixtures.amloc
    result.value = 0.0
    result.descendent_results = [40.0, 42.0]
    result.range = RangeFixtures.range_excellent
    result
  end

  def self.sc_result
    result = Kalibro::Entities::MetricResult.new
    result.metric = CompoundMetricFixtures.compound_metric
    result.value = 1.0
    result.descendent_results = [2.0, 42.0]
    result
  end

  def self.amloc_result_hash
    {:metric => NativeMetricFixtures.amloc_hash, :value => 0.0, :descendent_result => [40.0, 42.0],
      :range => RangeFixtures.range_excellent_hash,
      :attributes! => {:metric => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:nativeMetricXml'  }}}
  end

  def self.sc_result_hash
    {:metric => CompoundMetricFixtures.compound_metric_hash, :value => 1.0, :descendent_result => [2.0, 42.0],
      :attributes! => {:metric => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:compoundMetricXml'  }}}
  end

end
