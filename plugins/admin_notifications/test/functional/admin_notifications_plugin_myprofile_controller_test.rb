require File.expand_path(File.dirname(__FILE__)) + '/../../../../test/test_helper'
require(
  File.expand_path(File.dirname(__FILE__)) +
  '/../../controllers/admin_notifications_plugin_myprofile_controller'
)

class AdminNotificationsPluginMyprofileControllerTest < ActionController::TestCase
  def setup
    @controller = AdminNotificationsPluginMyprofileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @person = create_user('person').person
    @community = fast_create(Community)

    environment = Environment.default
    environment.enable_plugin('AdminNotificationsPlugin')
    environment.save!

    login_as(@person.user.login)
    AdminNotificationsPluginMyprofileController.any_instance.stubs(:profile).returns(@community)
  end

  attr_accessor :person

  should 'profile admin be able to create a notification' do
    @community.add_admin(@person)
    post :new, :profile => @community.identifier,
                :notifications => {
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

  should 'a regular user not to be able to create a notification' do
    post :new, :profile => @community.identifier,
    :notifications => {
      :message => "Message",
      :active => true,
      :type => "AdminNotificationsPlugin::DangerNotification"
    }

  assert_redirected_to :root
  assert_nil AdminNotificationsPlugin::Notification.last
  end

  should 'profile admin be able to edit a notification' do
    @community.add_admin(@person)
    @notification = AdminNotificationsPlugin::Notification.create(
      :target => @community,
      :message => "Message",
      :active => true,
      :type => "AdminNotificationsPlugin::DangerNotification"
    )

    post :edit, :profile => @community.identifier, :id => @notification.id,
    :notifications => {
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

  should 'a regular user not be able to edit a notification' do
    @notification = AdminNotificationsPlugin::Notification.create(
      :target => @community,
      :message => "Message",
      :active => true,
      :type => "AdminNotificationsPlugin::DangerNotification"
    )
    post :edit, :profile => @community.identifier,
    :notifications => {
      :message => "Edited Message",
      :active => false,
      :type => "AdminNotificationsPlugin::DangerNotification"
    }
    @notification.reload
    assert_redirected_to :root
    assert_equal "Message", @notification.message
    assert @notification.active
  end

  should 'a profile admin be able to destroy a notification' do
    @community.add_admin(@person)
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @community,
                      :message => "Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
    delete :destroy, :profile => @community.identifier, :id => @notification.id
    assert_nil AdminNotificationsPlugin::Notification.find_by_id(@notification.id)
  end

  should 'a regular user not be able to destroy a notification' do
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @community,
                      :message => "Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
    delete :destroy, :profile => @community.identifier, :id => @notification.id

    assert_redirected_to :root
    assert_not_nil AdminNotificationsPlugin::Notification.find_by_id(@notification.id)
  end

  should 'a profile admin be able to change Notification status' do
    @community.add_admin(@person)
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @community,
                      :message => "Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
    post :change_status, :profile => @community.identifier, :id => @notification.id
    assert_redirected_to :action => 'index'

    @notification.reload
    assert !@notification.active
  end

  should 'a regular user not be able to change Notification status' do
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @community,
                      :message => "Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
    post :change_status, :profile => @community.identifier, :id => @notification.id
    assert_redirected_to :root

    @notification.reload
    assert @notification.active
  end

end
