require File.dirname(__FILE__) + '/metric_fixtures'

class MetricConfigurationFixtures

  def self.amloc_metric_configuration
    amloc = Kalibro::MetricConfiguration.new amloc_metric_configuration_hash
    amloc.configuration_id = "13"
    amloc
  end

  def self.sc_metric_configuration
    sc = Kalibro::MetricConfiguration.new sc_metric_configuration_hash
    sc.configuration_id = "13"
    sc
  end
  
  def self.created_metric_configuration
    Kalibro::MetricConfiguration.new({
        :code => 'amloc',
        :metric => MetricFixtures.amloc_hash,
        :base_tool_name => "Analizo",
        :weight => "1.0",
        :aggregation_form => 'AVERAGE',
        :reading_group_id => "31",
        :configuration_id => "13"
      })
  end

  def self.amloc_metric_configuration_hash
    {
      :id => "42",
      :code => 'amloc',
      :metric => MetricFixtures.amloc_hash,
      :base_tool_name => "Analizo",
      :weight => "1.0",
      :aggregation_form => 'AVERAGE',
      :reading_group_id => "31",
      :attributes! => {:metric => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:metricXml'  }}
    }
  end

  def self.sc_metric_configuration_hash
    {
      :id => "42",
      :code => 'sc',
      :metric => MetricFixtures.compound_metric_hash,
      :weight => "1.0",
      :aggregation_form => 'AVERAGE',
      :reading_group_id => "31",
      :attributes! => {:metric => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:metricXml'  }}
    }
  end
    
end
