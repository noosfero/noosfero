require File.expand_path(File.dirname(__FILE__)) + '/../../../../test/test_helper'
require 'home_controller'

class HomeController; def rescue_action(e) raise e end;
end

class HomeControllerTest < ActionController::TestCase
  def setup
    @controller = HomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @person = create_user('person').person

    @environment = Environment.default
    @environment.enable_plugin('AdminNotificationsPlugin')
    @environment.save!
  end

  attr_accessor :person

  should 'an active notification be displayed on home page for a logged in user' do
    login_as(@person.user.login)
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Hello, this is a Notification Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
     get :index
     assert_match /Hello, this is a Notification Message/, @response.body
  end


  should 'an active notification not be displayed on home page for unlogged user' do
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Hello, this is a Notification Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
     get :index
     assert_no_match /Hello, this is a Notification Message/, @response.body
  end

  should 'an active notification be displayed on home page for unlogged user' do
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Hello, this is a Notification Message",
                      :display_to_all_users => true,
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
     get :index
     assert_match /Hello, this is a Notification Message/, @response.body
  end

  should 'only display the notification with display_to_all_users option for unlogged user ' do
    @notification1 = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Hello, this is an old Notification Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )

    @notification2 = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Hello, this is a new Notification Message",
                      :display_to_all_users => true,
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )


     get :index
     assert_no_match /Hello, this is a Notification Message/, @response.body
     assert_match /Hello, this is a new Notification Message/, @response.body
  end

  should 'an inactive notification not be displayed on home page' do
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Hello, this is a Notification Message",
                      :active => false,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
     get :index
     assert_no_match /Hello, this is a Notification Message/, @response.body
  end


  should 'an active notification not be displayed to a logged in user after been closed by him' do
    login_as(@person.user.login)
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Hello, this is a Notification Message",
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
     @notification.users << @person.user
     @notification.save!
     assert_equal true, @notification.users.include?(@person.user)
     get :index
     assert_no_match /Hello, this is a Notification Message/, @response.body
  end

  should 'a notification be displayed with a Popup' do
    login_as(@person.user.login)
    @notification = AdminNotificationsPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :display_popup => true,
                      :active => true,
                      :type => "AdminNotificationsPlugin::DangerNotification"
                    )
     assert_equal true, @notification.display_popup?

     get :index
     assert_no_match /div id="cboxWrapper"/, @response.body
  end
end
