require_relative '../../lib/push_notification_helper.rb'
require 'test_helper'

class NotificationSettingsTest < ActiveSupport::TestCase
  include  PushNotificationHelper

  should 'list notifications options in a hash' do
    user = User.create!(:login => 'homer', :email => 'homer@example.com', :password => 'beer', :password_confirmation => 'beer', :environment => Environment.default)
    user.activate
    settings = PushNotificationPlugin::NotificationSettings.create!(:user => user)
    user.reload
    assert_equivalent PushNotificationPlugin::NotificationSettings::NOTIFICATIONS.keys, settings.hash_flags.keys

    settings.hash_flags.each_pair do |notification, status|
      assert !!status == status
    end
  end

  should 'all notifications be disabled by default for new settingss' do
    user = User.create!(:login => 'outro', :email => 'outro@example.com', :password => 'outro', :password_confirmation => 'outro', :environment => Environment.default)
    user.activate
    settings = PushNotificationPlugin::NotificationSettings.create!(:user => user)
    settings.hash_flags.each_pair do |notification, status|
      refute status
    end
  end

  should 'activate a notification for a settings' do
    user = User.create!(:login => 'homer', :email => 'homer@example.com', :password => 'beer', :password_confirmation => 'beer', :environment => Environment.default)
    user.activate
    settings = PushNotificationPlugin::NotificationSettings.create!(:user => user)
    settings.activate_notification "new_comment"
    settings.save!

    assert_equal true, settings.hash_flags["new_comment"]
  end

  should 'deactivate a notification for a settings' do
    user = User.create!(:login => 'homer', :email => 'homer@example.com', :password => 'beer', :password_confirmation => 'beer', :environment => Environment.default)
    user.activate
    settings = PushNotificationPlugin::NotificationSettings.create!(:user => user)

    settings.activate_notification "new_comment"
    settings.save!
    assert_equal true, settings.hash_flags["new_comment"]

    settings.deactivate_notification "new_comment"
    settings.save!
    assert_equal false, settings.hash_flags["new_comment"]
  end

  should 'set notification to specific state' do
    user = User.create!(:login => 'homer', :email => 'homer@example.com', :password => 'beer', :password_confirmation => 'beer', :environment => Environment.default)
    user.activate
    settings = PushNotificationPlugin::NotificationSettings.new(:user => user)

    settings.set_notification_state "new_comment", 1
    settings.save!
    assert_equal true, settings.hash_flags["new_comment"]

    settings.set_notification_state "new_comment", 0
    settings.save!
    assert_equal false, settings.hash_flags["new_comment"]
  end

  should 'check if notification is active' do
    user = User.create!(:login => 'homer', :email => 'homer@example.com', :password => 'beer', :password_confirmation => 'beer', :environment => Environment.default)
    user.activate
    settings = PushNotificationPlugin::NotificationSettings.create!(:user => user)

    settings.activate_notification "new_comment"
    settings.save!

    assert_equal true, settings.active?("new_comment")
  end

  should 'list active notifications' do
    user = User.create!(:login => 'homer', :email => 'homer@example.com', :password => 'beer', :password_confirmation => 'beer', :environment => Environment.default)
    user.activate
    settings = PushNotificationPlugin::NotificationSettings.create!(:user => user)

    settings.activate_notification "new_comment"
    settings.save!
    assert_equivalent ["new_comment"], settings.active_notifications

    settings.activate_notification "add_friend"
    settings.save!
    assert_equivalent ["new_comment","add_friend"], settings.active_notifications
  end

  should 'list inactive notifications' do
    user = User.create!(:login => 'homer', :email => 'homer@example.com', :password => 'beer', :password_confirmation => 'beer', :environment => Environment.default)
    user.activate
    settings = PushNotificationPlugin::NotificationSettings.create!(:user => user)

    assert_equivalent PushNotificationPlugin::NotificationSettings::NOTIFICATIONS.keys, settings.inactive_notifications

    settings.activate_notification "new_comment"
    settings.save!
    assert_equivalent (PushNotificationPlugin::NotificationSettings::NOTIFICATIONS.keys-["new_comment"]), settings.inactive_notifications
  end
end
