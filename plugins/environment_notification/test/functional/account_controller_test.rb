require File.expand_path(File.dirname(__FILE__)) + '/../../../../test/test_helper'
require 'account_controller'

class AccountController
  include EnvironmentNotificationHelper
end

class AccountControllerTest < ActionController::TestCase
  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @person = create_user('person').person

    @environment = Environment.default
    @environment.enable_plugin('EnvironmentNotificationPlugin')
    @environment.save!

    login_as(@person.user.login)
  end

  attr_accessor :person

  should 'clean hide_notifications cookie after logout' do
    @request.cookies[:hide_notifications] = JSON.generate([1,2])
    get :index
    assert !@request.cookies[:hide_notifications].blank?

    @request.cookies[:hide_notifications] = nil
    get :logout
    assert_nil session[:user]
    assert_response :redirect
    assert_equal 1, @controller.hide_notifications.count
    assert @controller.hide_notifications.include?(-1)
  end
end
