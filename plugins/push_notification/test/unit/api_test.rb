require_relative '../../../../test/unit/api/test_helper'

class PushNotificationApiTest < ActiveSupport::TestCase

  def setup
    login_api
    environment = Environment.default
    environment.enable_plugin(PushNotificationPlugin)
  end

  should 'list all my device tokens' do
    logged_user = @user
    token1 = PushNotificationPlugin::DeviceToken.create!(:token => "firsttoken", device_name: "my device", :user => logged_user)
    token2 = PushNotificationPlugin::DeviceToken.create!(:token => "secondtoken", device_name: "my device", :user => logged_user)

    get "/api/v1/push_notification_plugin/device_tokens?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [token1.token, token2.token], json
  end

  should 'not list other people device tokens' do
    user = User.create!(:login => 'outro', :email => 'outro@example.com', :password => 'outro', :password_confirmation => 'outro', :environment => Environment.default)
    user.activate
    PushNotificationPlugin::DeviceToken.create!(:token => "firsttoken", device_name: "my device", :user => user)
    get "/api/v1/push_notification_plugin/device_tokens?#{params.merge(:target_id => user.id).to_query}"
    assert_equal 401, last_response.status
  end

  should 'admin see other user\'s device tokens' do
    logged_user = @user
    Environment.default.add_admin(logged_user.person)
    logged_user.reload

    user = User.create!(:login => 'outro', :email => 'outro@example.com', :password => 'outro', :password_confirmation => 'outro', :environment => Environment.default)
    user.activate

    token1 = PushNotificationPlugin::DeviceToken.create!(:token => "firsttoken", device_name: "my device", :user => user)

    get "/api/v1/push_notification_plugin/device_tokens?#{params.merge(:target_id => user.id).to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [token1.token], json
  end

#------------------------------------------------------------------------------------------------------

  should 'add my device token' do
    params.merge!(:device_name => "my_device", :token => "token1")
    post "/api/v1/push_notification_plugin/device_tokens?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent ["token1"], json["user"]["device_tokens"]
  end

  should 'not add device tokens for other people' do
    user = User.create!(:login => 'outro', :email => 'outro@example.com', :password => 'outro', :password_confirmation => 'outro', :environment => Environment.default)
    user.activate
    params.merge!(:device_name => "my_device", :token => "tokenX", :target_id => user.id)
    post "/api/v1/push_notification_plugin/device_tokens?#{params.to_query}"
    assert_equal 401, last_response.status
  end

  should 'admin add device tokens for other users' do
    logged_user = @user
    Environment.default.add_admin(logged_user.person)
    logged_user.reload

    user = User.create!(:login => 'outro', :email => 'outro@example.com', :password => 'outro', :password_confirmation => 'outro', :environment => Environment.default)
    user.activate

    params.merge!(:device_name => "my_device", :token=> "tokenY", :target_id => user.id)
    post "/api/v1/push_notification_plugin/device_tokens?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equivalent ["tokenY"], json["user"]["device_tokens"]
  end

#------------------------------------------------------------------------------------------------------

  should 'delete my device tokens' do
    logged_user = @user
    PushNotificationPlugin::DeviceToken.create!(:token => "firsttoken", device_name: "my device", :user => logged_user)
    PushNotificationPlugin::DeviceToken.create!(:token => "secondtoken", device_name: "my device", :user => logged_user)

    params.merge!(:token => "secondtoken")
    delete "/api/v1/push_notification_plugin/device_tokens?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent ["firsttoken"], json["user"]["device_tokens"]
  end

  should 'not delete device tokens for other people' do
    user = User.create!(:login => 'outro', :email => 'outro@example.com', :password => 'outro', :password_confirmation => 'outro', :environment => Environment.default)
    user.activate

    PushNotificationPlugin::DeviceToken.create!(:token => "secondtoken", device_name: "my device", :user => user)
    user.reload

    params.merge!(:token => "secondtoken", :target_id => user.id)
    delete "/api/v1/push_notification_plugin/device_tokens?#{params.to_query}"
    assert_equal 401, last_response.status
    assert_equivalent user.device_token_list, ["secondtoken"]
  end

  should 'admin delete device tokens for other users' do
    logged_user = @user
    Environment.default.add_admin(logged_user.person)
    logged_user.reload

    user = User.create!(:login => 'outro', :email => 'outro@example.com', :password => 'outro', :password_confirmation => 'outro', :environment => Environment.default)
    user.activate

    PushNotificationPlugin::DeviceToken.create!(:token => "firsttoken", device_name: "my device", :user => user)
    PushNotificationPlugin::DeviceToken.create!(:token => "secondtoken", device_name: "my device", :user => user)
    user.reload

    params.merge!(:token=> "secondtoken", :target_id => user.id)
    delete "/api/v1/push_notification_plugin/device_tokens?#{params.to_query}"

    json = JSON.parse(last_response.body)
    assert_equivalent ["firsttoken"], json["user"]["device_tokens"]
  end

#--------------------------------------------------------------------------------------------------------------------------------------------

  should 'list all notifications disabled by default for new users' do
    get "/api/v1/push_notification_plugin/notification_settings?#{params.to_query}"
    json = JSON.parse(last_response.body)
    json["user"]["notification_settings"].each_pair do |notification, status|
      refute status
    end
  end

  should 'list device tokens notification options' do
    logged_user = @user
    logged_user.notification_settings.activate_notification "new_comment"
    logged_user.save!

    get "/api/v1/push_notification_plugin/notification_settings?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal true, json["user"]["notification_settings"]["new_comment"]
		assert_equal false, json["user"]["notification_settings"]["add_friend"]
  end

  should 'get possible notifications' do
    get "/api/v1/push_notification_plugin/possible_notifications?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent PushNotificationPlugin::NotificationSettings::NOTIFICATIONS.keys, json["possible_notifications"]
  end

  should 'change device tokens notification options' do
    logged_user = @user
    params.merge!("new_comment"=> "true")

    post "/api/v1/push_notification_plugin/notification_settings?#{params.to_query}"
		logged_user.reload
    json = JSON.parse(last_response.body)
    assert_equal true, json["user"]["notification_settings"]["new_comment"]
		assert_equal true, logged_user.notification_settings.hash_flags["new_comment"]
	end

  should 'get active notifications list' do
    logged_user = @user
    logged_user.notification_settings.activate_notification "new_comment"
    logged_user.save!

    get "/api/v1/push_notification_plugin/active_notifications?#{params.to_query}"
    json = JSON.parse(last_response.body)
		assert_equivalent ["new_comment"], json
  end

  should 'get inactive notifications list' do
    logged_user = @user
    logged_user.notification_settings.activate_notification "new_comment"
    logged_user.save

    get "/api/v1/push_notification_plugin/inactive_notifications?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent (PushNotificationPlugin::NotificationSettings::NOTIFICATIONS.keys-["new_comment"]), json
  end
end
