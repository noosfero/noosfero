require_relative '../../../../test/test_helper'

class EnvironmentNotificationTest < ActiveSupport::TestCase

  def setup
    @env = Environment.default
    @env.enable_plugin('EnvironmentNotificationPlugin')

    User.destroy_all
    EnvironmentNotificationPlugin::EnvironmentNotification.destroy_all
    EnvironmentNotificationsUser.destroy_all

    @user = User.create!(:environment_id => @env.id, :email => "user@domain.com", :login   => "new_user", :password => "test", :password_confirmation => "test")
    @danger_notification = EnvironmentNotificationPlugin::DangerNotification.create!(
                      :environment_id => @env.id,
                      :message => "Danger Message",
                      :active => true,
                    )

    @warning_notification = EnvironmentNotificationPlugin::WarningNotification.create!(
                      :environment_id => @env.id,
                      :message => "Warning Message",
                      :active => true,
                    )

    @information_notification = EnvironmentNotificationPlugin::InformationNotification.create!(
                      :environment_id => @env.id,
                      :message => "Information Message",
                      :active => true,
                    )
  end

  should 'get all notifications that a user did not closed' do
    @information_notification.users << @user

    notifications = EnvironmentNotificationPlugin::EnvironmentNotification.visibles(@env, @user, nil)

    assert notifications.include?(@danger_notification)
    assert notifications.include?(@warning_notification)
    assert !notifications.include?(@information_notification)
  end

  should 'get only notifications configured to be displayed to all users' do
    @information_notification.display_to_all_users = true
    @information_notification.save!

    notifications = EnvironmentNotificationPlugin::EnvironmentNotification.visibles(@env, nil, nil)

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

    notifications = EnvironmentNotificationPlugin::EnvironmentNotification.visibles(@env, nil, 'not_home')

    assert notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert !notifications.include?(@information_notification)
  end

  should 'get only notifications configured to be displayed in all pages' do
    @danger_notification.display_to_all_users = true
    @danger_notification.display_only_in_homepage = true
    @danger_notification.save!

    notifications = EnvironmentNotificationPlugin::EnvironmentNotification.visibles(@env, @user, "not_home")

    assert !notifications.include?(@danger_notification)
    assert notifications.include?(@warning_notification)
    assert notifications.include?(@information_notification)

    notifications = EnvironmentNotificationPlugin::EnvironmentNotification.visibles(@env, nil, "home")

    assert notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert !notifications.include?(@information_notification)
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

    notifications = EnvironmentNotificationPlugin::EnvironmentNotification.visibles(@env, @user, 'not_home')

    assert !notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert notifications.include?(@information_notification)
  end

  should 'get only active notifications' do
    @information_notification.active = false
    @information_notification.save!

    notifications = EnvironmentNotificationPlugin::EnvironmentNotification.visibles(@env, @user, 'home')

    assert notifications.include?(@danger_notification)
    assert notifications.include?(@warning_notification)
    assert !notifications.include?(@information_notification)
  end

  should 'get only notifications with popup' do
    @information_notification.display_popup = true
    @information_notification.display_to_all_users = true
    @information_notification.save!

    notifications = EnvironmentNotificationPlugin::EnvironmentNotification.with_popup(@env, @user, 'home')

    assert !notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert notifications.include?(@information_notification)

    notifications = EnvironmentNotificationPlugin::EnvironmentNotification.with_popup(@env, nil, nil)

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

    notifications = EnvironmentNotificationPlugin::EnvironmentNotification.with_popup(@env, @user, 'home')

    assert !notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert notifications.include?(@information_notification)

    notifications = EnvironmentNotificationPlugin::EnvironmentNotification.with_popup(@env, nil, nil)

    assert notifications.include?(@danger_notification)
    assert !notifications.include?(@warning_notification)
    assert notifications.include?(@information_notification)
  end
end
