require "test_helper"

class ContentViewerHelperTest < ActiveSupport::TestCase

  should 'get the number rounded by two decimal points' do
    assert_equal '4.22', MezuroPlugin::Helpers::ContentViewerHelper.format_grade('4.22344')
    assert_equal '4.10', MezuroPlugin::Helpers::ContentViewerHelper.format_grade('4.1')
    assert_equal '4.00', MezuroPlugin::Helpers::ContentViewerHelper.format_grade('4')
  end

  should 'create the periodicity options array' do
    assert_equal [["Not Periodically", 0], ["1 day", 1], ["2 days", 2], ["Weekly", 7], ["Biweeky", 15], ["Monthly", 30]], MezuroPlugin::Helpers::ContentViewerHelper.create_periodicity_options
  end
end
