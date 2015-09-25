require File.expand_path(File.dirname(__FILE__)) + '/../../../../test/test_helper'
require(
  File.expand_path(File.dirname(__FILE__)) +
  '/../../controllers/environment_notification_plugin_admin_controller'
)

class EnvironmentNotificationPluginAdminController; def rescue_action(e) raise e end;
end

class EnvironmentNotificationPluginAdminControllerTest < ActionController::TestCase
  def setup
    @controller = EnvironmentNotificationPluginAdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @person = create_user('person').person

    @environment = Environment.default
    @environment.enable_plugin('EnvironmentNotificationPlugin')
    @environment.save!

    login_as(@person.user.login)
  end

  attr_accessor :person

  should 'an admin be able to create a notification' do
    @environment.add_admin(@person)
     post :new, :notifications => {
                  :message => "Message",
                  :active => true,
                  :type => "EnvironmentNotificationPlugin::DangerNotification"
                }
     assert_redirected_to :action => 'index'
     notification = EnvironmentNotificationPlugin::EnvironmentNotification.last
     assert_equal "Message", notification.message
     assert notification.active
     assert_equal "EnvironmentNotificationPlugin::DangerNotification", notification.type
  end

  should 'an user not to be able to create a notification' do
     post :new, :notifications => {
                  :message => "Message",
                  :active => true,
                  :type => "EnvironmentNotificationPlugin::DangerNotification"
                }
     assert_redirected_to :root
     assert_nil EnvironmentNotificationPlugin::EnvironmentNotification.last
  end

   should 'an admin be able to edit a notification' do
    @environment.add_admin(@person)
    @notification = EnvironmentNotificationPlugin::EnvironmentNotification.create(
                      :environment_id => @environment.id,
                      :message => "Message",
                      :active => true,
                      :type => "EnvironmentNotificationPlugin::DangerNotification"
                    )
     post :edit, :id => @notification.id, :notifications => {
                                            :message => "Edited Message",
                                            :active => false,
                                            :type => "EnvironmentNotificationPlugin::WarningNotification"
                                          }
     @notification = EnvironmentNotificationPlugin::EnvironmentNotification.last
     assert_redirected_to :action => 'index'
     assert_equal "Edited Message", @notification.message
     assert !@notification.active
     assert_equal "EnvironmentNotificationPlugin::WarningNotification", @notification.type
  end

  should 'an user not to be able to edit a notification' do
    @notification = EnvironmentNotificationPlugin::EnvironmentNotification.create(
                      :environment_id => @environment.id,
                      :message => "Message",
                      :active => true,
                      :type => "EnvironmentNotificationPlugin::DangerNotification"
                    )
     post :edit, :notifications => {
                   :message => "Edited Message",
                   :active => false,
                   :type => "EnvironmentNotificationPlugin::DangerNotification"
                 }
     @notification.reload
     assert_redirected_to :root
     assert_equal "Message", @notification.message
     assert @notification.active
  end

  should 'an admin be able to destroy a notification' do
    @environment.add_admin(@person)
    @notification = EnvironmentNotificationPlugin::EnvironmentNotification.create(
                      :environment_id => @environment.id,
                      :message => "Message",
                      :active => true,
                      :type => "EnvironmentNotificationPlugin::DangerNotification"
                    )
    delete :destroy, :id => @notification.id
    assert_nil EnvironmentNotificationPlugin::EnvironmentNotification.find_by_id(@notification.id)
  end

  should 'an user not to be able to destroy a notification' do
    @notification = EnvironmentNotificationPlugin::EnvironmentNotification.create(
                      :environment_id => @environment.id,
                      :message => "Message",
                      :active => true,
                      :type => "EnvironmentNotificationPlugin::DangerNotification"
                    )
     delete :destroy, :id => @notification.id

     assert_redirected_to :root
     assert_not_nil EnvironmentNotificationPlugin::EnvironmentNotification.find_by_id(@notification.id)
  end

  should 'an admin be able to change Notification status' do
    @environment.add_admin(@person)
    @notification = EnvironmentNotificationPlugin::EnvironmentNotification.create(
                      :environment_id => @environment.id,
                      :message => "Message",
                      :active => true,
                      :type => "EnvironmentNotificationPlugin::DangerNotification"
                    )
     post :change_status, :id => @notification.id
     assert_redirected_to :action => 'index'

     @notification.reload
     assert !@notification.active
  end

  should 'an user not be able to change Notification status' do
    @notification = EnvironmentNotificationPlugin::EnvironmentNotification.create(
                      :environment_id => @environment.id,
                      :message => "Message",
                      :active => true,
                      :type => "EnvironmentNotificationPlugin::DangerNotification"
                    )
     post :change_status, :id => @notification.id
     assert_redirected_to :root

     @notification.reload
     assert @notification.active
  end

  should 'a logged in user be able to permanently hide notifications' do
    @notification = EnvironmentNotificationPlugin::EnvironmentNotification.create(
                      :environment_id => @environment.id,
                      :message => "Message",
                      :active => true,
                      :type => "EnvironmentNotificationPlugin::DangerNotification"
                    )
     post :close_notification, :notification_id => @notification.id
     assert_equal "true", @response.body
     assert @notification.users.include?(@person.user)
  end

  should 'a logged in user be able to momentarily hide notifications' do
    @notification = EnvironmentNotificationPlugin::EnvironmentNotification.create(
                      :environment_id => @environment.id,
                      :message => "Message",
                      :active => true,
                      :type => "EnvironmentNotificationPlugin::DangerNotification"
                    )

    @another_notification = EnvironmentNotificationPlugin::EnvironmentNotification.create(
                      :environment_id => @environment.id,
                      :message => "Another Message",
                      :active => true,
                      :type => "EnvironmentNotificationPlugin::WarningNotification"
                    )
     post :hide_notification, :notification_id => @notification.id
     assert_equal "true", @response.body
     assert @controller.hide_notifications.include?(@notification.id)
     assert !@controller.hide_notifications.include?(@another_notification.id)
  end

  should 'not momentarily hide any notification if its id is not found' do
    @notification = EnvironmentNotificationPlugin::EnvironmentNotification.create(
                      :environment_id => @environment.id,
                      :message => "Message",
                      :active => true,
                      :type => "EnvironmentNotificationPlugin::DangerNotification"
                    )

     post :hide_notification, :notification_id => nil
     assert_equal "false", @response.body
     assert !@controller.hide_notifications.include?(@notification.id)
  end
end
