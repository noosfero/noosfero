require File.dirname(__FILE__) + '/compound_metric_fixtures'
require File.dirname(__FILE__) + '/native_metric_fixtures'
require File.dirname(__FILE__) + '/range_fixtures'

class MetricResultFixtures

  def self.native_metric_result
    Kalibro::MetricResult.new native_metric_result_hash
  end

  def self.compound_metric_result
    Kalibro::MetricResult.new compound_metric_result_hash
  end

  def self.native_metric_result_hash
    {
      :metric => NativeMetricFixtures.amloc_hash,
      :value => 0.0,
      :descendent_result => [40.0, 42.0],
      :range => RangeFixtures.range_excellent_hash,
      :attributes! => {
        :metric => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:nativeMetricXml'  },
        :range => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:rangeXml'  }
      }
    }
  end

  def self.compound_metric_result_hash
    {
      :metric => CompoundMetricFixtures.compound_metric_hash,
      :value => 1.0,
      :descendent_result => [2.0, 42.0],
      :attributes! => {
        :metric => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:compoundMetricXml'  }
      }
    }
  end

end
