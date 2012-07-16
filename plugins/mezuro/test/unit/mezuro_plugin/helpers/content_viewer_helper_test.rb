require "test_helper"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_result_fixtures"

class ContentViewerHelperTest < ActiveSupport::TestCase

  should 'get the number rounded by two decimal points' do
    assert_equal '4.22', MezuroPlugin::Helpers::ContentViewerHelper.format_grade('4.22344')
    assert_equal '4.10', MezuroPlugin::Helpers::ContentViewerHelper.format_grade('4.1')
    assert_equal '4.00', MezuroPlugin::Helpers::ContentViewerHelper.format_grade('4')
  end

  should 'create the periodicity options array' do
    assert_equal [["Not Periodically", 0], ["1 day", 1], ["2 days", 2], ["Weekly", 7], ["Biweeky", 15], ["Monthly", 30]], MezuroPlugin::Helpers::ContentViewerHelper.create_periodicity_options
  end
  
  should 'format metric name for module result' do
    metric_result = MetricResultFixtures.native_metric_result
    assert_equal 'AverageMethodLOC', MezuroPlugin::Helpers::ContentViewerHelper.format_name(metric_result)
  end
end
