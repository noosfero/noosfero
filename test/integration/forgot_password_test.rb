require "#{File.dirname(__FILE__)}/../test_helper"

class ForgotPasswordTest < ActionController::IntegrationTest

  def test_forgot_password

    User.destroy_all
    Profile.destroy_all
    ChangePassword.destroy_all

    User.create!(:login => 'forgotten', :password => 'test', :password_confirmation => 'test', :email => 'forgotten@localhost.localdomain')

    get '/account/forgot_password'

    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => '/account/forgot_password', :method => 'post' }

    post '/account/forgot_password', :change_password => { :login => 'forgotten', :email => 'forgotten@localhost.localdomain' }

    assert_response :success
    assert_template 'password_recovery_sent'

    assert_equal 1, ChangePassword.count
    code = ChangePassword.find(:first).code

    get "/account/new_password/#{code}"
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => "/account/new_password/#{code}" }

    post "/account/new_password/#{code}", :change_password => { :password => 'newpass', :password_confirmation => 'newpass'}
    assert_response :success
    assert_template 'new_password_ok'
    assert_tag :tag => 'a', :attributes => { :href => "/account/login" }

    assert User.find_by_login('forgotten').authenticated?('newpass')
  end

end
