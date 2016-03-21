require File.expand_path(File.dirname(__FILE__)) + '/../../../../test/test_helper'
require(
  File.expand_path(File.dirname(__FILE__)) +
  '/../../controllers/public/admin_notifications_plugin_public_controller'
)

class AdminNotificationsPluginPublicControllerTest < ActionController::TestCase
  def setup
    @controller = AdminNotificationsPluginPublicController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @person = create_user('person').person

    @environment = Environment.default
    @environment.enable_plugin('AdminNotificationsPlugin')
    @environment.save!

    login_as(@person.user.login)
  end

  should 'a logged in user be able to permanently hide notifications' do
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
     post :close_notification, :notification_id => @notification.id
     assert_equal "true", @response.body
     assert @notification.users.include?(@person.user)
  end

  should 'a logged in user be able to momentarily hide notifications' do
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )

    @another_notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Another Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::WarningNotification"
                    )
     post :hide_notification, :notification_id => @notification.id
     assert_equal "true", @response.body
     assert @controller.hide_notifications.include?(@notification.id)
     assert !@controller.hide_notifications.include?(@another_notification.id)
  end

  should 'not momentarily hide any notification if its id is not found' do
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )

     post :hide_notification, :notification_id => nil
     assert_equal "false", @response.body
     assert !@controller.hide_notifications.include?(@notification.id)
  end
end
