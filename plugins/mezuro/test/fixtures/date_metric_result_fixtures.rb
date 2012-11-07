require File.dirname(__FILE__) + '/metric_result_fixtures'

class DateMetricResultFixtures

  def self.date_metric_result
    Kalibro::DateMetricResult.new date_metric_result_hash
  end

  def self.date_metric_result_hash
    {
      :date => '2011-10-20T18:26:43.151+00:00',
      :metric_result => MetricResultFixtures.native_metric_result_hash,
      :attributes! =>
      {
        :metric_result =>
        {
          "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
          "xsi:type"=>"kalibro:metricResultXml"
        }
      }
    }
  end

end
