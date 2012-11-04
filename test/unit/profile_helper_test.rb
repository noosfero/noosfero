require File.dirname(__FILE__) + '/../test_helper'

class ProfileHelperTest < ActiveSupport::TestCase

  include ProfileHelper
  include ApplicationHelper
  include ActionView::Helpers::TagHelper

  def setup
    @profile = mock
    @helper = mock
    helper.extend(ProfileHelper)
  end
  attr_reader :profile, :helper

  should 'not display field if field is not active and not forced' do
    profile.expects(:active_fields).returns([])
    assert_equal '', display_field('Title', profile, 'field')
  end

  should 'display field if field is not active but is forced' do
    profile.expects(:active_fields).returns([])
    profile.expects(:field).returns('value')
    assert_match /Title.*value/, display_field('Title', profile, 'field', true)
  end

  should 'not display field if field is active but not public and not logged in' do
    profile.stubs(:active_fields).returns(['field'])
    profile.expects(:public_fields).returns([])
    @controller = mock
    @controller.stubs(:user).returns(nil)
    assert_equal '', display_field('Title', profile, 'field')
  end

  should 'not display field if field is active but not public and user is not friend' do
    profile.stubs(:active_fields).returns(['field'])
    profile.expects(:public_fields).returns([])
    user = mock
    user.expects(:is_a_friend?).with(profile).returns(false)
    @controller = mock
    @controller.stubs(:user).returns(user)
    assert_equal '', display_field('Title', profile, 'field')
  end

  should 'display field if field is active and not public but user is profile owner' do
    profile.stubs(:active_fields).returns(['field'])
    profile.expects(:public_fields).returns([])
    profile.expects(:field).returns('value')
    @controller = mock
    @controller.stubs(:user).returns(profile)
    assert_match /Title.*value/, display_field('Title', profile, 'field', true)
  end

  should 'display field if field is active and not public but user is a friend' do
    profile.stubs(:active_fields).returns(['field'])
    profile.expects(:public_fields).returns([])
    profile.expects(:field).returns('value')
    user = mock
    user.expects(:is_a_friend?).with(profile).returns(true)
    @controller = mock
    @controller.stubs(:user).returns(user)
    assert_match /Title.*value/, display_field('Title', profile, 'field', true)
  end

  should 'not display work info if field is active but not public and user is not friend' do
    profile.stubs(:active_fields).returns(['organization', 'organization_website'])
    profile.expects(:public_fields).returns([]).times(2)
    user = mock
    user.expects(:is_a_friend?).with(profile).returns(false).times(2)
    @controller = mock
    @controller.stubs(:user).returns(user)
    assert_equal '', display_work_info(profile)
  end

  should 'display work info if field is active and not public but user is profile owner' do
    profile.stubs(:active_fields).returns(['organization', 'organization_website'])
    profile.expects(:public_fields).returns([]).times(2)
    profile.expects(:organization).returns('Organization Name')
    profile.expects(:organization_website).returns('')
    @controller = mock
    @controller.stubs(:user).returns(profile)
    assert_match /Work.*Organization Name/, display_work_info(profile)
  end

  should 'display work info if field is active and not public but user is a friend' do
    profile.stubs(:active_fields).returns(['organization', 'organization_website'])
    profile.expects(:public_fields).returns([]).times(2)
    profile.expects(:organization).returns('Organization Name')
    profile.expects(:organization_website).returns('')
    user = mock
    user.expects(:is_a_friend?).with(profile).returns(true).times(2)
    @controller = mock
    @controller.stubs(:user).returns(user)
    assert_match /Work.*Organization Name/, display_work_info(profile)
  end

end
