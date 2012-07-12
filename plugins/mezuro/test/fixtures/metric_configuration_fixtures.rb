require File.dirname(__FILE__) + '/compound_metric_fixtures'
require File.dirname(__FILE__) + '/native_metric_fixtures'
require File.dirname(__FILE__) + '/range_fixtures'

class MetricConfigurationFixtures

  def self.amloc_metric_configuration
    amloc = Kalibro::MetricConfiguration.new amloc_metric_configuration_hash
    amloc.configuration_name = "Sample Configuration"
    amloc
  end

  def self.metric_configuration_without_ranges
    amloc = Kalibro::MetricConfiguration.new 
      {
        :metric => NativeMetricFixtures.amloc_hash,
        :code => 'amloc',
        :weight => 1.0,
        :aggregation_form => 'AVERAGE'
      }
    amloc.configuration_name = "Sample Configuration"
    amloc
  end

  def self.sc_metric_configuration
    sc = Kalibro::MetricConfiguration.new sc_metric_configuration_hash
    sc.configuration_name = "Sample Configuration"
    sc
  end

  def self.amloc_metric_configuration_hash
    {:metric => NativeMetricFixtures.amloc_hash, :code => 'amloc', :weight => 1.0,
      :aggregation_form => 'AVERAGE',
      :range => [RangeFixtures.range_excellent_hash, RangeFixtures.range_bad_hash],
      :attributes! => {:metric => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:nativeMetricXml'  }}}
  end

  def self.sc_metric_configuration_hash
    {:metric => CompoundMetricFixtures.compound_metric_hash, :code => 'sc', :weight => 1.0, :aggregation_form => 'AVERAGE',
      :attributes! => {:metric => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:compoundMetricXml'  }}}
  end
    
end
