require File.dirname(__FILE__) + '/metric_configuration_snapshot_fixtures'
require File.dirname(__FILE__) + '/throwable_fixtures'

class MetricResultFixtures

  def self.native_metric_result
    Kalibro::MetricResult.new native_metric_result_hash
  end

  def self.compound_metric_result
    Kalibro::MetricResult.new compound_metric_result_hash
  end

  def self.metric_result_with_error_hash
    {
      :id => "41",
      :configuration => MetricConfigurationSnapshotFixtures.metric_configuration_snapshot_hash,
      :error => ThrowableFixtures.throwable_hash
    }
  end

  def self.native_metric_result_hash
    {
      :id => "42",
      :configuration => MetricConfigurationSnapshotFixtures.metric_configuration_snapshot_hash,
      :value => "0.0",
      :attributes! =>
      {
        :configuration =>
        {
          "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
          "xsi:type"=>"kalibro:metricConfigurationSnapshotXml"
        }
      }
    }
  end

  def self.compound_metric_result_hash
    {
      :id => "43",
      :configuration => MetricConfigurationSnapshotFixtures.compound_metric_configuration_snapshot_hash,
      :value => "1.0",
      :attributes! =>
      {
        :configuration =>
        {
          "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
          "xsi:type"=>"kalibro:metricConfigurationSnapshotXml"
        }
      }
    }
  end

end
