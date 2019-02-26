# encoding: UTF-8
require_relative "../../../../test_helper"

class Entitlement::Checks::Profile::ViewPrivateContentTest < ActiveSupport::TestCase
  def setup
    @user = create_user('user').person
    @profile = fast_create(Profile)
    @check = Entitlement::Checks::Profile::ViewPrivateContent.new(@profile)
  end

  attr_reader :user, :profile, :check

  should 'not entitle nil user' do
    refute check.entitles?(nil)
  end

  should 'not entitle random user' do
    user.stubs(:has_permission?).with(:view_private_content, profile).returns(false)
    refute check.entitles?(user)
  end

  should 'entitle the user with permission' do
    user.stubs(:has_permission?).with(:view_private_content, profile).returns(true)
    assert check.entitles?(user)
  end
end
