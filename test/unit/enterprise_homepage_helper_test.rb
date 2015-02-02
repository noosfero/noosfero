require_relative "../test_helper"

class EnterpriseHomepageHelperTest < ActiveSupport::TestCase

  include EnterpriseHomepageHelper

  def setup
    @profile = mock
    profile.stubs(:profile_image).returns('profileimage.png')
    self.stubs(:url_for).returns('link to profile')
    profile.stubs(:name).returns('Name of Profile')
    profile.stubs(:url).returns('')
    profile.stubs(:products).returns([Product.new(:name => 'product test')])
    profile.stubs(:identifier).returns('name-of-profile')
    profile.stubs(:region).returns(Region.new(:name => 'Brazil'))
    profile.stubs(:address).returns('Address of Profile')
    profile.stubs(:contact_email).returns('Email of Profile')
    profile.stubs(:contact_phone).returns('Phone of Profile')
    profile.stubs(:contact_person).returns('Profile Owner')
    profile.stubs(:location).returns('Profile Location');
    profile.stubs(:economic_activity).returns('Profile Economic Activity');
  end
  attr_reader :profile

  should 'display profile info' do
    result = display_profile_info(profile)
    assert_match /Profile Owner/, result
    assert_match /Email of Profile/, result
    assert_match /Phone of Profile/, result
    assert_match /Profile Location/, result
    assert_match /Address of Profile/, result
    assert_match /Profile Economic Activity/, result
  end

  should 'not display attribute if nil' do
    profile.stubs(:contact_person).returns(nil);
    result = display_profile_info(profile)
    assert_no_match /Profile Owner/, result
  end

  should 'not display attribute if blank' do
    profile.stubs(:contact_person).returns('');
    result = display_profile_info(profile)
    assert_no_match /Profile Owner/, result
  end

  should 'display distance' do
    profile.stubs(:distance).returns(100.345);
    result = display_profile_info(profile)
    assert_match /Distance:/, result
    assert_match /100.34/, result    
  end

  should 'not display distance if nil' do
    profile.stubs(:distance).returns(nil);
    result = display_profile_info(profile)
    assert_no_match /Distance:/, result
    assert_no_match /100.34/, result    
  end

  protected
  include NoosferoTestHelper

end
