require "test_helper"

class ContentViewerHelperTest < ActiveSupport::TestCase

  should 'get the number rounded by two decimal points' do
    assert_equal '4.22', MezuroPlugin::Helpers::ContentViewerHelper.format_grade('4.22344')
    assert_equal '4.10', MezuroPlugin::Helpers::ContentViewerHelper.format_grade('4.1')
    assert_equal '4.00', MezuroPlugin::Helpers::ContentViewerHelper.format_grade('4')
  end
end
