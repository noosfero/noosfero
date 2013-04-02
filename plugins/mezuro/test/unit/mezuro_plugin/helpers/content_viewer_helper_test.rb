require "test_helper"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_snapshot_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/date_metric_result_fixtures"

class ContentViewerHelperTest < ActiveSupport::TestCase

  def setup
    @helper = MezuroPlugin::Helpers::ContentViewerHelper
  end

  should 'get the number rounded by two decimal points' do
    assert_equal '4.22', @helper.format_grade('4.22344')
    assert_equal '4.10', @helper.format_grade('4.1')
    assert_equal '4.00', @helper.format_grade('4')
  end

  should 'create the periodicity options array' do
    assert_equal [["Not Periodically", 0], ["1 day", 1], ["2 days", 2], ["Weekly", 7], ["Biweekly", 15], ["Monthly", 30]], @helper.periodicity_options
  end

  should 'return the correct string for a given periodicity' do
    assert_equal "Not Periodically", @helper.periodicity_option(0)
    assert_equal "1 day", @helper.periodicity_option(1)
    assert_equal "2 days", @helper.periodicity_option(2)
    assert_equal "Weekly", @helper.periodicity_option(7)
    assert_equal "Biweekly", @helper.periodicity_option(15)
    assert_equal "Monthly", @helper.periodicity_option(30)
  end

  should 'create the license options array' do
   options = YAML.load_file("#{RAILS_ROOT}/plugins/mezuro/licenses.yml")
   options = options.split("; ")
   assert_equal options, @helper.license_options
  end
  
  should 'generate chart from metric result history' do
    chart = "http://chart.apis.google.com/chart?chxt=y,x&chco=c4a000&chf=bg,ls,90,efefef,0.2,ffffff,0.2&chd=s:A9&chl=2011-10-20T18%3A26%3A43%2B00%3A00|2011-10-25T18%3A26%3A43%2B00%3A00&cht=lc&chs=600x180&chxr=0,0.0,5.0"
    metric_history = DateMetricResultFixtures.score_history

    assert_equal chart, @helper.generate_chart(metric_history)
  end

  should 'format time to show a sentence' do
    assert_equal 'less than 5 seconds', @helper.format_time(0)
    assert_equal 'less than 5 seconds', @helper.format_time(4999)
    assert_equal 'less than 10 seconds', @helper.format_time(5000)
    assert_equal '1 minute', @helper.format_time(70000)
    assert_equal 'about 2 hours', @helper.format_time(7000000)
  end

  should 'format metric name for metric configuration snapshot' do
    metric_configuration_snapshot = MetricConfigurationSnapshotFixtures.metric_configuration_snapshot
    assert_equal 'AverageMethodLOC', @helper.format_name(metric_configuration_snapshot)
  end

  should 'create aggregation options array' do
    assert_equal [["Average","AVERAGE"], ["Median", "MEDIAN"], ["Maximum", "MAXIMUM"], ["Minimum", "MINIMUM"], 
    ["Count", "COUNT"], ["Standard Deviation", "STANDARD_DEVIATION"]], @helper.aggregation_options
  end

  should 'create scope options' do
    assert_equal [["Software", "SOFTWARE"], ["Package", "PACKAGE"], ["Class", "CLASS"], ["Method", "METHOD"]], @helper.scope_options
  end

end
