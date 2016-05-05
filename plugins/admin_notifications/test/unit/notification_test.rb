require_relative '../../../../test/test_helper'
require_relative '../helpers/notification_test_helper'

class NotificationTest < ActiveSupport::TestCase

  include NotificationTestHelper

  def setup
    @env = Environment.default
    @env.enable_plugin('AdminNotificationsPlugin')

    @user = User.create!(:environment_id => @env.id, :email => "user@domain.com", :login   => "new_user", :password => "test", :password_confirmation => "test")
    @danger_notification = AdminNotificationsPlugin::DangerNotification.create!(
                      :target => @env,
                      :message => "Danger Message",
                      :active => true,
                    )

    @warning_notification = AdminNotificationsPlugin::WarningNotification.create!(
                      :target => @env,
                      :message => "Warning Message",
                      :active => true,
                    )

    @information_notification = AdminNotificationsPlugin::InformationNotification.create!(
                      :target => @env,
                      :message => "Information Message",
                      :active => true,
                    )
  end

  should 'get all notifications that a user did not close' do
    @information_notification.users << @user

    notifications = AdminNotificationsPlugin::Notification.visibles(@env, @user, nil)

    assert notifications.include?(@danger_notification)
    assert notifications.include?(@warning_notification)
    assert !notifications.include?(@information_notification)
  end

  should 'get only notifications configured to be displayed to all users' do
    @information_notification.display_to_all_users = true
    @information_notification.save!

    notifications = AdminNotificationsPlugin::Notification.visibles(@env, nil, nil)

    assert !notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert notifications.include?(@information_notification)
  end

  should 'get only notifications configured to be displayed to all users and in all pages' do
    @information_notification.display_to_all_users = true
    @information_notification.display_only_in_homepage = true
    @information_notification.save!

    @danger_notification.display_to_all_users = true
    @danger_notification.save!

    @warning_notification.display_only_in_homepage = true
    @warning_notification.save!

    notifications = AdminNotificationsPlugin::Notification.visibles(@env, nil, 'not_home')

    assert notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert !notifications.include?(@information_notification)
  end

  should 'get only notifications configured to be displayed in all pages' do
    @danger_notification.display_to_all_users = true
    @danger_notification.display_only_in_homepage = true
    @danger_notification.save!

    notifications = AdminNotificationsPlugin::Notification.visibles(@env, @user, "not_home")

    assert !notifications.include?(@danger_notification)
    assert notifications.include?(@warning_notification)
    assert notifications.include?(@information_notification)

    notifications = AdminNotificationsPlugin::Notification.visibles(@env, nil, "home")

    assert notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert !notifications.include?(@information_notification)
  end

  should 'get notifications configured to be displayed on profile' do
    community = fast_create(Community)

    AdminNotificationsPlugin::Notification.destroy_all
    env_home_notification = create_notification(@env, true)
    env_not_home_notification = create_notification(@env, false)
    profile_not_home_notification = create_notification(community, false)
    profile_home_notification = create_notification(community, true)

    notifications = AdminNotificationsPlugin::Notification.visibles(community, @user, "profile")
    assert_equivalent notifications.to_a, [env_not_home_notification, profile_not_home_notification, profile_home_notification]

    notifications = AdminNotificationsPlugin::Notification.visibles(community, @user, "profile_but_bot_homepage")
    assert_equivalent notifications.to_a, [env_not_home_notification, profile_not_home_notification]
  end

  should 'get notifications configured to be displayed on environment' do
    community = fast_create(Community)

    AdminNotificationsPlugin::Notification.destroy_all
    env_home_notification = create_notification(@env, true)
    env_not_home_notification = create_notification(@env, false)
    profile_not_home_notification = create_notification(community, false)
    profile_home_notification = create_notification(community, true)

    notifications = AdminNotificationsPlugin::Notification.visibles(@env, @user, "home")
    assert_equivalent notifications.to_a, [env_home_notification, env_not_home_notification]

    notifications = AdminNotificationsPlugin::Notification.visibles(@env, @user, "not_home_not_profile")
    assert_equivalent notifications.to_a, [env_not_home_notification]
  end

  should 'get only notifications configured to be displayed to all users and in all pages and not closed by an user' do
    @information_notification.display_to_all_users = true
    @information_notification.save!

    @danger_notification.display_to_all_users = true
    @danger_notification.display_only_in_homepage = true
    @danger_notification.save!

    @warning_notification.display_to_all_users = true
    @warning_notification.save!

    @warning_notification.users << @user

    notifications = AdminNotificationsPlugin::Notification.visibles(@env, @user, 'not_home')

    assert !notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert notifications.include?(@information_notification)
  end

  should 'get only active notifications' do
    @information_notification.active = false
    @information_notification.save!

    notifications = AdminNotificationsPlugin::Notification.visibles(@env, @user, 'home')

    assert notifications.include?(@danger_notification)
    assert notifications.include?(@warning_notification)
    assert !notifications.include?(@information_notification)
  end

  should 'get only notifications with popup' do
    @information_notification.display_popup = true
    @information_notification.display_to_all_users = true
    @information_notification.save!

    notifications = AdminNotificationsPlugin::Notification.with_popup(@env, @user, 'home')

    assert !notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert notifications.include?(@information_notification)

    notifications = AdminNotificationsPlugin::Notification.with_popup(@env, nil, nil)

    assert !notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert notifications.include?(@information_notification)
  end

  should 'get only notifications with popup not closed by an user' do
    @information_notification.display_popup = true
    @information_notification.display_to_all_users = true
    @information_notification.save!

    @danger_notification.display_popup = true
    @danger_notification.display_to_all_users = true
    @danger_notification.save!

    @danger_notification.users << @user

    notifications = AdminNotificationsPlugin::Notification.with_popup(@env, @user, 'home')

    assert !notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert notifications.include?(@information_notification)

    notifications = AdminNotificationsPlugin::Notification.with_popup(@env, nil, nil)

    assert notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert notifications.include?(@information_notification)
  end
end
