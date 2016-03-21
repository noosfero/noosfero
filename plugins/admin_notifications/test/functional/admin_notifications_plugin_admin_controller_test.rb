require 'test_helper'
require_relative '../../controllers/admin_notifications_plugin_admin_controller'

class AdminNotificationsPluginAdminControllerTest < ActionController::TestCase
  def setup
    @controller = AdminNotificationsPluginAdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @person = create_user('person').person

    @environment = Environment.default
    @environment.enable_plugin('AdminNotificationsPlugin')
    @environment.save!

    login_as(@person.user.login)
  end

  attr_accessor :person

  should 'an admin be able to create a notification' do
    @environment.add_admin(@person)
     post :new, :notifications => {
                  :message => "Message",
                  :active => true,
                  :type => "AdminNotificationsPlugin::DangerNotification"
                }
     assert_redirected_to :action => 'index'
     notification = AdminNotificationsPlugin::Notification.last
     assert_equal "Message", notification.message
     assert notification.active
     assert_equal "AdminNotificationsPlugin::DangerNotification", notification.type
  end

  should 'an user not to be able to create a notification' do
     post :new, :notifications => {
                  :message => "Message",
                  :active => true,
                  :type => "AdminNotificationsPlugin::DangerNotification"
                }
     assert_redirected_to :root
     assert_nil AdminNotificationsPlugin::Notification.last
  end

   should 'an admin be able to edit a notification' do
    @environment.add_admin(@person)
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
     post :edit, :id => @notification.id, :notifications => {
                                            :message => "Edited Message",
                                            :active => false,
                                            :type => "AdminNotificationsPlugin::WarningNotification"
                                          }
     @notification = AdminNotificationsPlugin::Notification.last
     assert_redirected_to :action => 'index'
     assert_equal "Edited Message", @notification.message
     assert !@notification.active
     assert_equal "AdminNotificationsPlugin::WarningNotification", @notification.type
  end

  should 'an user not to be able to edit a notification' do
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
     post :edit, :notifications => {
                   :message => "Edited Message",
                   :active => false,
                   :type => "AdminNotificationsPlugin::DangerNotification"
                 }
     @notification.reload
     assert_redirected_to :root
     assert_equal "Message", @notification.message
     assert @notification.active
  end

  should 'an admin be able to destroy a notification' do
    @environment.add_admin(@person)
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
    delete :destroy, :id => @notification.id
    assert_nil AdminNotificationsPlugin::Notification.find_by id: @notification.id
  end

  should 'an user not to be able to destroy a notification' do
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
     delete :destroy, :id => @notification.id

     assert_redirected_to :root
     assert_not_nil AdminNotificationsPlugin::Notification.find_by id: @notification.id
  end

  should 'an admin be able to change Notification status' do
    @environment.add_admin(@person)
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
     post :change_status, :id => @notification.id
     assert_redirected_to :action => 'index'

     @notification.reload
     assert !@notification.active
  end

  should 'an user not be able to change Notification status' do
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
     post :change_status, :id => @notification.id
     assert_redirected_to :root

     @notification.reload
     assert @notification.active
  end

end
