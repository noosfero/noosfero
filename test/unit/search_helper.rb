require File.dirname(__FILE__) + '/../test_helper'

class SearchHelperTest < Test::Unit::TestCase

  include SearchHelper

  def setup
    @profile = mock
  end
  attr_reader :profile

  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::TagHelper
  should 'display profile info' do
    profile.expects(:name).returns('Name of Profile')
    profile.stubs(:url).returns('')

    self.expects(:profile_image).returns('profileimage.png')
    self.expects(:url_for).returns('merda')
    self.expects(:link_to).returns('link to profile')

    result = self.display_profile_info(profile)
    assert_match /profileimage.png/, result
    assert_match /link to profile/, result
    assert_match /<strong>Name of Profile<\/strong>/, result
  end

end
