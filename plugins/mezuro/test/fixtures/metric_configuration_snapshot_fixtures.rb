require File.dirname(__FILE__) + '/metric_fixtures'
require File.dirname(__FILE__) + '/range_snapshot_fixtures'

class MetricConfigurationSnapshotFixtures

  def self.metric_configuration_snapshot
    Kalibro::MetricConfigurationSnapshot.new metric_configuration_snapshot_hash
  end

  def self.metric_configuration_snapshot_hash
    {
      :code => "code",
      :weight => "1.0",
      :aggregation_form => 'AVERAGE',
      :metric => MetricFixtures.amloc_hash,
      :base_tool_name => "Analizo",
      :range => [RangeSnapshotFixtures.range_snapshot_hash],
      :attributes! => {
        :metric => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:metricXml'  },
        :range => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:rangeSnapshotXml'  }
      }
    }
  end

  def self.metric_configuration_snapshot_with_2_elements
    Kalibro::MetricConfigurationSnapshot.new  metric_configuration_snapshot_hash_with_2_elements
  end

  def self.metric_configuration_snapshot_hash_with_2_elements
    hash = self.metric_configuration_snapshot_hash
    hash[:range] << RangeSnapshotFixtures.range_snapshot_hash
    hash
  end

  def self.compound_metric_configuration_snapshot
    Kalibro::MetricConfigurationSnapshot.new compound_metric_configuration_snapshot_hash
  end

  def self.compound_metric_configuration_snapshot_hash
    {
      :code => "code",
      :weight => "1.0",
      :aggregation_form => 'AVERAGE',
      :metric => MetricFixtures.compound_metric,
      :base_tool_name => "Analizo",
      :range => [RangeSnapshotFixtures.range_snapshot_hash],
      :attributes! => {
        :metric => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:metricXml'  },
        :range => {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:rangeSnapshotXml'  }
      }
    }
  end

end
