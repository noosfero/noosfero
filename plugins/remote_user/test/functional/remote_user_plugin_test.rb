require 'test_helper'

class AccountControllerTest < ActionController::TestCase
  def setup
    @environment = Environment.default
    @environment.enabled_plugins = ['RemoteUserPlugin']
    @environment.save

    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'not authenticate user if there is no remote user' do
    get :index
    assert_nil session[:user]
  end

  should 'authenticate user if its a valid remote user' do
    user = create_user('testuser', :email => 'testuser@example.com', :password => 'test', :password_confirmation => 'test')
    user.activate
    @request.env["HTTP_REMOTE_USER"] = user.login
    get :index
    assert session[:user]
  end

  should 'authenticate another user if the remote user doesnt belong to the current user' do
    user1 = create_user('testuser', :email => 'testuser@example.com', :password => 'test', :password_confirmation => 'test')
    user1.activate
    user2 = create_user('anotheruser', :email => 'anotheruser@example.com', :password => 'test', :password_confirmation => 'test')
    user2.activate

    login_as user1.login
    assert_equal user1.id, session[:user]

    @request.env["HTTP_REMOTE_USER"] = user2.login
    get :index

    assert_equal user2.id, session[:user]
  end

  should 'create a new user with remote_user_data if the remote user does not exist' do
    User.destroy_all

    assert_equal 0, User.count

    @request.env["HTTP_REMOTE_USER"] = "testuser"
    @request.env["CONTENT_TYPE"] = "application/json"
    @request.env["HTTP_REMOTE_USER_DATA"] = '{"email":"testuser@domain.com", "name":"Test User"}'
    get :index

    assert_equal 1, User.count
    assert_equal "testuser", User.last.login
    assert_equal true, User.last.activated?
    assert_equal User.last.id, session[:user]
    assert_equal "Test User", User.last.name
    assert_equal "testuser@domain.com", User.last.email
  end

  should 'create a new user with remote_user_data even if there is a logged user but the remote user is different' do
    users = User.count

    user = create_user('testuser', :email => 'testuser@example.com', :password => 'test', :password_confirmation => 'test')
    user.activate

    login_as user.login

    @request.env["HTTP_REMOTE_USER"] = 'another_user'
    @request.env["CONTENT_TYPE"] = "application/json"
    @request.env["HTTP_REMOTE_USER_DATA"] = '{"email":"another_user@domain.com", "name":"Another User"}'
    get :index

    assert_equal users + 2, User.count
    assert_equal "another_user", User.last.login
    assert_equal true, User.last.activated?
    assert_equal User.last.id, session[:user]
    assert_equal "Another User", User.last.name
    assert_equal "another_user@domain.com", User.last.email
  end

  should 'create a new user without remote_user_data if the remote user does not exist' do
    User.destroy_all

    assert_equal 0, User.count

    @request.env["HTTP_REMOTE_USER"] = "testuser"
    get :index

    assert_equal 1, User.count
    assert_equal "testuser", User.last.login
    assert_equal true, User.last.activated?
    assert_equal User.last.id, session[:user]
    assert_equal "testuser", User.last.name
    assert_equal "testuser@remote.user", User.last.email
  end

  should 'create a new user without remote_user_data even if there is a logged user but the remote user is different' do
    users = User.count

    user = create_user('testuser', :email => 'testuser@example.com', :password => 'test', :password_confirmation => 'test')
    user.activate

    login_as user.login

    @request.env["HTTP_REMOTE_USER"] = 'another_user'
    get :index

    assert_equal users + 2, User.count
    assert_equal "another_user", User.last.login
    assert_equal true, User.last.activated?
    assert_equal User.last.id, session[:user]
    assert_equal "another_user", User.last.name
    assert_equal "another_user@remote.user", User.last.email
  end

  should 'logout if there is a current logged user but not a remote user' do
    user1 = create_user('testuser', :email => 'testuser@example.com', :password => 'test', :password_confirmation => 'test')
    user1.activate

    login_as user1.login

    get :index

    assert session[:user].blank?

    @request.env["HTTP_REMOTE_USER"] = ""
    get :index

    assert session[:user].blank?
  end

  should 'not create a new user if his informations is invalid' do
    @request.env["HTTP_REMOTE_USER"] = "*%&invalid user name&%*"
    get :index

    assert session[:user].blank?
    assert_response 404
  end
end
