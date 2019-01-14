require 'test_helper'

class AccountController
  include AdminNotificationsPlugin::NotificationHelper
end

class AccountControllerTest < ActionController::TestCase
  def setup
    @controller = AccountController.new

    @person = create_user('person').person

    @environment = Environment.default
    @environment.enable_plugin('AdminNotificationsPlugin')
    @environment.save!

    login_as(@person.user.login)
    @request.cookies[:hide_notifications] = JSON.generate([1,2])
  end

  attr_accessor :person

  should 'not clean hide_notifications cookie if user is not logged out' do
    get :index

    refute cookies[:hide_notifications].blank?
  end

  should 'clean hide_notifications cookie after logout' do
    logout
    get :index

    assert_equal [-1], @controller.hide_notifications
    assert cookies[:hide_notifications].blank?
  end
end
