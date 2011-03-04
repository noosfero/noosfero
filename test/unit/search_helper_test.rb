require File.dirname(__FILE__) + '/../test_helper'

class SearchHelperTest < Test::Unit::TestCase

  include SearchHelper

  def _(any)
    any
  end

  def setup
    @profile = mock
    self.stubs(:profile_image).returns('profileimage.png')
    self.stubs(:url_for).returns('link to profile')
    profile.stubs(:name).returns('Name of Profile')
    profile.stubs(:url).returns('')
    profile.stubs(:products).returns([Product.new(:name => 'product test')])
    profile.stubs(:identifier).returns('name-of-profile')
    profile.stubs(:region).returns(Region.new(:name => 'Brazil'))
  end
  attr_reader :profile

  should 'display profile info' do
    profile.stubs(:address).returns('Address of Profile')
    profile.stubs(:contact_email).returns('Email of Profile')
    profile.stubs(:contact_phone).returns('Phone of Profile')

    result = self.display_profile_info(profile)
    assert_match /profileimage.png/, result
    assert_match /link to profile/, result
    assert_match /Email of Profile/, result
    assert_match /Phone of Profile/, result
    assert_match /Address of Profile/, result
  end

  should 'not display field if nil in profile info' do
    profile.stubs(:address).returns('nil')
    profile.stubs(:contact_email).returns('nil')
    profile.stubs(:contact_phone).returns('nil')

    result = self.display_profile_info(profile)
    assert_match /profileimage.png/, result
    assert_match /link to profile/, result
    assert_no_match /Email of Profile/, result
    assert_no_match /Phone of Profile/, result
    assert_no_match /Address of Profile/, result
  end

  should 'link to products and services of an profile' do
    enterprise = fast_create(Enterprise)
    product1 = fast_create(Product, :enterprise_id => enterprise.id)
    product2 = fast_create(Product, :enterprise_id => enterprise.id)
    result = display_profile_info(enterprise)
    assert_tag_in_string result, :tag => 'a', :attributes => {:href => /:id=>#{product1.id}/}, :content => product1.name
    assert_tag_in_string result, :tag => 'a', :attributes => {:href => /:id=>#{product2.id}/}, :content => product2.name
  end

  should 'link to manage_products controller on display_profile_info' do
    enterprise = fast_create(Enterprise)
    product = fast_create(Product, :enterprise_id => enterprise.id)
    result = display_profile_info(enterprise)
    assert_tag_in_string result, :tag => 'a', :attributes => {:href => /:controller=>\"manage_products\"/}, :content => product.name
    assert_no_tag_in_string result, :tag => 'a', :attributes => {:href => /:id=>\"catalog\"/}, :content => product.name
  end

  protected
  include NoosferoTestHelper

end
