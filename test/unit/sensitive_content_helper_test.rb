require_relative "../test_helper"

class SensitiveContentHelperTest < ActionView::TestCase

  include SensitiveContentHelper

  def setup
    @user_admin = create_user('user_admin').person
    @env = Environment.default
    @env.add_admin(@user_admin)
    @common_user = create_user('common_user').person
  end

  attr :user_admin
  attr :common_user


  should 'should return the user identifier if the profile is nil' do

    assert_equal user_admin.identifier, profile_to_publish(user_admin, nil)
    assert_equal common_user.identifier, profile_to_publish(common_user, nil)

  end

  should 'should return the user identifier if the profile is the user\'s own' do

    assert_equal user_admin.identifier, profile_to_publish(user_admin, user_admin)
    assert_equal common_user.identifier, profile_to_publish(common_user, common_user)

  end

  should 'should return the user identifier if the profile belongs to another user' do

    assert_equal user_admin.identifier, profile_to_publish(user_admin, common_user)
    assert_equal common_user.identifier, profile_to_publish(common_user, user_admin)

  end

  should 'should return the community identifier if the profile is a community that
            the user is allowed to publish content' do

    profile = fast_create(Community)
    profile.add_admin(common_user)

    assert_equal profile.identifier, profile_to_publish(common_user, profile)

  end

  should 'should return the user identifier if the profile is a community that
            the user isn\'t allowed to publish content' do

    profile = fast_create(Community)
    assert_equal common_user.identifier, profile_to_publish(common_user, profile)

  end

  should 'should return the community identifier if the profile is a community and
            the user is a member and system admin' do

    profile = fast_create(Community)
    profile.add_member(user_admin)

    assert_equal profile.identifier, profile_to_publish(user_admin, profile)

  end

  should 'should return the community identifier if the profile is a community and
            the user isn\'t a member but is a system admin' do

    profile = fast_create(Community)

    assert_equal profile.identifier, profile_to_publish(user_admin, profile)

  end

  should 'should return the enterprise identifier if the profile is a enterprise that
            the user is allowed to publish content' do

    profile = fast_create(Enterprise)
    profile.add_admin(common_user)

    assert_equal profile.identifier, profile_to_publish(common_user, profile)

  end

  should 'should return the user identifier if the profile is a enterprise that
            the user isn\'t allowed to publish content' do

    profile = fast_create(Enterprise)
    assert_equal common_user.identifier, profile_to_publish(common_user, profile)

  end

  should 'should return the enterprise identifier if the profile is a enterprise and
            the user is a member and system admin' do

    profile = fast_create(Enterprise)
    profile.add_member(user_admin)

    assert_equal profile.identifier, profile_to_publish(user_admin, profile)

  end

  should 'should return the enterprise identifier if the profile is a enterprise and
            the user isn\'t a member but is a system admin' do

    profile = fast_create(Enterprise)

    assert_equal profile.identifier, profile_to_publish(user_admin, profile)

  end
end

