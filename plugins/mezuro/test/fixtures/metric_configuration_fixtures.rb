require File.dirname(__FILE__) + '/compound_metric_fixtures'
require File.dirname(__FILE__) + '/native_metric_fixtures'
require File.dirname(__FILE__) + '/range_fixtures'

class MetricConfigurationFixtures

  def self.amloc_configuration
    amloc = Kalibro::Entities::MetricConfiguration.new
    amloc.metric = NativeMetricFixtures.amloc
    amloc.code = 'amloc'
    amloc.weight = 1.0
    amloc.aggregation_form = 'AVERAGE'
    amloc.ranges = [RangeFixtures.amloc_excellent, RangeFixtures.amloc_bad]
    amloc
  end

  def self.metric_configuration_without_ranges
    amloc = Kalibro::Entities::MetricConfiguration.new
    amloc.metric = NativeMetricFixtures.amloc
    amloc.code = 'amloc'
    amloc.weight = 1.0
    amloc.aggregation_form = 'AVERAGE'
    amloc
  end

  def self.sc_configuration
    sc = Kalibro::Entities::MetricConfiguration.new
    sc.metric = CompoundMetricFixtures.sc
    sc.code = 'sc'
    sc.weight = 1.0
    sc.aggregation_form = 'AVERAGE'
    sc
  end

  def self.amloc_configuration_hash
    {:metric => NativeMetricFixtures.amloc_hash, :code => 'amloc', :weight => 1.0,
      :aggregation_form => 'AVERAGE',
      :range => [RangeFixtures.amloc_excellent_hash, RangeFixtures.amloc_bad_hash],
      :attributes! => {:metric => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:nativeMetricXml'  }}}
  end

  def self.sc_configuration_hash
    {:metric => CompoundMetricFixtures.sc_hash, :code => 'sc', :weight => 1.0, :aggregation_form => 'AVERAGE',
      :attributes! => {:metric => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:compoundMetricXml'  }}}
  end
    
end
