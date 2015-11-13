require_relative 'test_helper'

class SessionTest < ActiveSupport::TestCase

  def setup
    login_api
  end

  should 'generate private token when login' do
    params = {:login => "testapi", :password => "testapi"}
    post "/api/v1/login?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert !json['user']["private_token"].blank?
  end

  should 'return 401 when login fails' do
    user.destroy
    params = {:login => "testapi", :password => "testapi"}
    post "/api/v1/login?#{params.to_query}"
    assert_equal 401, last_response.status
  end

  should 'register a user' do
    Environment.default.enable('skip_new_user_email_confirmation')
    params = {:login => "newuserapi", :password => "newuserapi", :password_confirmation => "newuserapi", :email => "newuserapi@email.com" }
    post "/api/v1/register?#{params.to_query}"
    assert_equal 201, last_response.status
    json = JSON.parse(last_response.body)
    assert User['newuserapi'].activated?
    assert json['user']['activated']
    assert json['user']['private_token'].present?
  end

  should 'register a user with name' do
    Environment.default.enable('skip_new_user_email_confirmation')
    params = {:login => "newuserapi", :password => "newuserapi", :password_confirmation => "newuserapi", :email => "newuserapi@email.com", :name => "Little John" }
    post "/api/v1/register?#{params.to_query}"
    assert_equal 201, last_response.status
    json = JSON.parse(last_response.body)
    assert json['user']['activated']
    assert json['user']['private_token'].present?
  end

  should 'register an inactive user' do
    params = {:login => "newuserapi", :password => "newuserapi", :password_confirmation => "newuserapi", :email => "newuserapi@email.com" }
    post "/api/v1/register?#{params.to_query}"
    assert_equal 201, last_response.status
    json = JSON.parse(last_response.body)
    assert !json['activated']
    assert json['private_token'].blank?
  end

  should 'not register a user with invalid login' do
    params = {:login => "c", :password => "newuserapi", :password_confirmation => "newuserapi", :email => "newuserapi@email.com" }
    post "/api/v1/register?#{params.to_query}"
    assert_equal 400, last_response.status
    json = JSON.parse(last_response.body)
    msg = json['message'].split(':')
    key = msg[0][2, 5]
    val = msg[1][2, 38]
    assert_equal "login", key
    assert_equal "is too short (minimum is 2 characters)", val
  end

  should 'not register a user with invalid login pt' do
    I18n.locale = "pt-BR"
    params = {:lang => "pt-BR", :login => "c", :password => "newuserapi", :password_confirmation => "newuserapi", :email => "newuserapi@email.com" }
    post "/api/v1/register?#{params.to_query}"
    assert_equal 400, last_response.status
    json = JSON.parse(last_response.body)
    msg = json['message'].split(':')
    key = msg[0][2, 5]
    val = msg[1][2, 35]
    assert_equal "login", key
    assert val.include? "muito curto"
  end

  should 'not register a user without email' do
    params = {:login => "newuserapi", :password => "newuserapi", :password_confirmation => "newuserapi", :email => nil }
    post "/api/v1/register?#{params.to_query}"
    assert_equal 400, last_response.status
  end

  should 'not register a duplicated user' do
    params = {:login => "newuserapi", :password => "newuserapi", :password_confirmation => "newuserapi", :email => "newuserapi@email.com" }
    post "/api/v1/register?#{params.to_query}"
    post "/api/v1/register?#{params.to_query}"
    assert_equal 400, last_response.status
    json = JSON.parse(last_response.body)
  end

  # TODO: Add another test cases to check register situations
  should 'activate a user' do
    params = {
      :login => "newuserapi",
      :password => "newuserapi",
      :password_confirmation => "newuserapi",
      :email => "newuserapi@email.com"
    }
    user = User.new(params)
    user.save!

    params = { activation_code: user.activation_code}
    patch "/api/v1/activate?#{params.to_query}"
    assert_equal 200, last_response.status
  end

  should 'do not activate a user if admin must approve him' do
    params = {
      :login => "newuserapi",
      :password => "newuserapi",
      :password_confirmation => "newuserapi",
      :email => "newuserapi@email.com",
      :environment => Environment.default
    }
    user = User.new(params)
    user.environment.enable('admin_must_approve_new_users')
    user.save!

    params = { activation_code: user.activation_code}
    patch "/api/v1/activate?#{params.to_query}"
    assert_equal 202, last_response.status
    assert_equal 'Waiting for admin moderate user registration', JSON.parse(last_response.body)["message"]
  end

  should 'do not activate a user if the token is invalid' do
    params = {
      :login => "newuserapi",
      :password => "newuserapi",
      :password_confirmation => "newuserapi",
      :email => "newuserapi@email.com",
      :environment => Environment.default
    }
    user = User.new(params)
    user.save!

    params = { activation_code: '70250abe20cc6a67ef9399cf3286cb998b96aeaf'}
    patch "/api/v1/activate?#{params.to_query}"
    assert_equal 412, last_response.status
  end

  should 'create task to change password by user login' do
    user = create_user
    params = {:value => user.login}
    assert_difference 'ChangePassword.count' do
      post "/api/v1/forgot_password?#{params.to_query}"
    end
  end

  should 'not create task to change password when user is not found' do
    params = {:value => 'wronglogin'}
    assert_no_difference 'ChangePassword.count' do
      post "/api/v1/forgot_password?#{params.to_query}"
    end
    assert_equal 404, last_response.status
  end

  should 'change user password and close task' do
    task = ChangePassword.create!(:requestor => @person)
    params.merge!({:code => task.code, :password => 'secret', :password_confirmation => 'secret'})
    patch "/api/v1/new_password?#{params.to_query}"
    assert_equal Task::Status::FINISHED, task.reload.status
    assert user.reload.authenticated?('secret')
    json = JSON.parse(last_response.body)
    assert_equal user.id, json['user']['id']
  end

  should 'do not change user password when password confirmation is wrong' do
    user = create_user
    user.activate
    task = ChangePassword.create!(:requestor => user.person)
    params = {:code => task.code, :password => 'secret', :password_confirmation => 's3cret'}
    patch "/api/v1/new_password?#{params.to_query}"
    assert_equal Task::Status::ACTIVE, task.reload.status
    assert !user.reload.authenticated?('secret')
    assert_equal 400, last_response.status
  end

  should 'render not found when provide a wrong code on password change' do
    params = {:code => "wrongcode", :password => 'secret', :password_confirmation => 'secret'}
    patch "/api/v1/new_password?#{params.to_query}"
    assert_equal 404, last_response.status
  end

end
