require File.dirname(__FILE__) + '/../test_helper'

class SearchHelperTest < ActiveSupport::TestCase

  include SearchHelper

  def _(any)
    any
  end

  def setup
    @profile = mock
  end
  attr_reader :profile

  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::TagHelper
  should 'display profile info' do
    profile.stubs(:name).returns('Name of Profile')
    profile.stubs(:address).returns('Address of Profile')
    profile.stubs(:contact_email).returns('Email of Profile')
    profile.stubs(:contact_phone).returns('Phone of Profile')
    profile.stubs(:url).returns('')
    profile.stubs(:products).returns([Product.new(:name => 'product test')])
    profile.stubs(:identifier).returns('name-of-profile')
    profile.stubs(:region).returns(Region.new(:name => 'Brazil'))

    self.stubs(:profile_image).returns('profileimage.png')
    self.stubs(:url_for).returns('merda')
    self.stubs(:link_to).returns('link to profile')

    result = self.display_profile_info(profile)
    assert_match /profileimage.png/, result
    assert_match /link to profile/, result
    assert_match /Email of Profile/, result
    assert_match /Phone of Profile/, result
    assert_match /Address of Profile/, result
  end

  should 'not display field if nil in profile info' do
    profile.stubs(:name).returns('Name of Profile')
    profile.stubs(:address).returns('nil')
    profile.stubs(:contact_email).returns('nil')
    profile.stubs(:contact_phone).returns('nil')
    profile.stubs(:url).returns('')
    profile.stubs(:products).returns([Product.new(:name => 'product test')])
    profile.stubs(:identifier).returns('name-of-profile')
    profile.stubs(:region).returns(Region.new(:name => 'Brazil'))

    self.stubs(:profile_image).returns('profileimage.png')
    self.stubs(:url_for).returns('merda')
    self.stubs(:link_to).returns('link to profile')

    result = self.display_profile_info(profile)
    assert_match /profileimage.png/, result
    assert_match /link to profile/, result
    assert_no_match /Email of Profile/, result
    assert_no_match /Phone of Profile/, result
    assert_no_match /Address of Profile/, result
  end

end
