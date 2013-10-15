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

  should 'display field if may display it' do
    self.stubs(:user).returns(nil)
    profile.expects(:may_display_field_to?).returns(true)
    profile.expects(:field).returns('value')
    assert_match /Title.*value/, display_field('Title', profile, 'field')
  end

  should 'not display field if may not display it and not forced' do
    self.stubs(:user).returns(nil)
    profile.expects(:may_display_field_to?).returns(false)
    assert_equal '', display_field('Title', profile, 'field')
  end

  should 'display field if may not display it but is forced' do
    self.stubs(:user).returns(nil)
    profile.stubs(:may_display_field_to?).returns(false)
    profile.expects(:field).returns('value')
    assert_match /Title.*value/, display_field('Title', profile, 'field', true)
  end

  should 'display work info if at least one of the fields should be displayed' do
    self.stubs(:user).returns(nil)
    profile.stubs(:may_display_field_to?).with(:organization, nil).returns(true)
    profile.stubs(:may_display_field_to?).with(:organization_website, nil).returns(false)
    profile.expects(:organization).returns('Organization Name')
    profile.expects(:organization_website).never
    assert_match /Work.*Organization Name/, display_work_info(profile)
  end

  should 'not display work info if none of the fields should be displayed' do
    self.stubs(:user).returns(nil)
    profile.stubs(:may_display_field_to?).returns(false)
    profile.expects(:organization).never
    profile.expects(:organization_website).never
    assert_equal '', display_work_info(profile)
  end

  should 'display work info if both fields should be displayed' do
    self.stubs(:user).returns(nil)
    profile.stubs(:may_display_field_to?).returns(true)
    profile.expects(:organization).returns('Organization Name')
    profile.expects(:organization_website).returns('')
    assert_match /Work.*Organization Name/, display_work_info(profile)
  end

end
