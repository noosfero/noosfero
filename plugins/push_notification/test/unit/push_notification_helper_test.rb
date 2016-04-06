require_relative '../../lib/push_notification_helper.rb'
require 'test_helper'

class PushNotificationHelperTest < ActiveSupport::TestCase
  include  PushNotificationHelper

  should 'get all tokens for a group of users' do
    user = User.create!(:login => 'homer', :email => 'homer@example.com', :password => 'beer', :password_confirmation => 'beer', :environment => Environment.default)
    user.activate
    PushNotificationPlugin::DeviceToken.create!(:token => "tokenHomer1", device_name: "my device", :user => user)
    PushNotificationPlugin::DeviceToken.create!(:token => "tokenHomer2", device_name: "my device", :user => user)

    user2 = User.create!(:login => 'bart', :email => 'bart@example.com', :password => 'fart', :password_confirmation => 'fart', :environment => Environment.default)
    user2.activate
    PushNotificationPlugin::DeviceToken.create!(:token => "tokenBart1", device_name: "my device", :user => user2)
    PushNotificationPlugin::DeviceToken.create!(:token => "tokenBart2", device_name: "my device", :user => user2)
    PushNotificationPlugin::DeviceToken.create!(:token => "tokenBart3", device_name: "my device", :user => user2)

    tokens = tokens_for_users([user,user2])

    assert_equivalent ["tokenHomer1","tokenHomer2","tokenBart1","tokenBart2","tokenBart3"], tokens
  end

  should 'filter users registered for a notification' do
    user = User.create!(:login => 'homer', :email => 'homer@example.com', :password => 'beer', :password_confirmation => 'beer', :environment => Environment.default)
    user.activate
    user2 = User.create!(:login => 'bart', :email => 'bart@example.com', :password => 'fart', :password_confirmation => 'fart', :environment => Environment.default)
    user2.activate

    user.notification_settings.activate_notification "new_comment"
    user.save!

    users = filter_users_for_flag("new_comment",[user,user2])

    assert_equivalent [user], users
  end

end
