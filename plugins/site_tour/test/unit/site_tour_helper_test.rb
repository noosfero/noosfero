require 'test_helper'

class SiteTourHelperTest < ActionView::TestCase

  include SiteTourPlugin::SiteTourHelper

  should 'parse tooltip description' do
    assert_equal 'test', parse_tour_description("test")
  end

  should 'replace profile attributes in tooltip description' do
    profile = fast_create(Profile)
    expects(:profile).returns(profile).at_least_once
    assert_equal "name #{profile.name}, identifier #{profile.identifier}, url #{url_for profile.url}", parse_tour_description("name {profile.name}, identifier {profile.identifier}, url {profile.url}")
  end

end
