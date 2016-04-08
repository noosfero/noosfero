require_relative "../test_helper"

class ForgotPasswordTest < ActionDispatch::IntegrationTest

  def setup
    ActionDispatch::Integration::Session.any_instance.stubs(:https?).returns(true)
  end

  def test_forgot_password_with_login

    User.destroy_all
    Profile.destroy_all
    ChangePassword.destroy_all

    create_user('forgotten', :password => 'test', :password_confirmation => 'test', :email => 'forgotten@localhost.localdomain').activate

    get '/account/forgot_password'

    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => '/account/forgot_password', :method => 'post' }

    post '/account/forgot_password', :field => 'login', :value => 'forgotten', :environment_id => Environment.default.id

    assert_response :success
    assert_template 'password_recovery_sent'

    assert_equal 1, ChangePassword.count
    code = ChangePassword.first.code

    get "/account/new_password/#{code}"
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => "/account/new_password/#{code}" }

    post "/account/new_password/#{code}", :change_password => { :password => 'newpass', :password_confirmation => 'newpass'}
    assert_response :success
    assert_template 'new_password_ok'
    assert_tag :tag => 'a', :attributes => { :href => "/account/login" }

    login('forgotten', 'newpass')
  end

  def test_forgot_password_with_email

    User.destroy_all
    Profile.destroy_all
    ChangePassword.destroy_all

    create_user('forgotten', :password => 'test', :password_confirmation => 'test', :email => 'forgotten@localhost.localdomain').activate

    get '/account/forgot_password'

    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => '/account/forgot_password', :method => 'post' }

    post '/account/forgot_password', :field => 'email', :value => 'forgotten@localhost.localdomain', :environment_id => Environment.default.id

    assert_response :success
    assert_template 'password_recovery_sent'

    assert_equal 1, ChangePassword.count
    code = ChangePassword.first.code

    get "/account/new_password/#{code}"
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => "/account/new_password/#{code}" }

    post "/account/new_password/#{code}", :change_password => { :password => 'newpass', :password_confirmation => 'newpass'}
    assert_response :success
    assert_template 'new_password_ok'
    assert_tag :tag => 'a', :attributes => { :href => "/account/login" }

    login('forgotten', 'newpass')
  end

end
