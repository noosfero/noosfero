require File.dirname(__FILE__) + '/../../../../test/test_helper'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

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

  should 'create a new user if the remote user does not exist' do
    User.destroy_all

    assert_equal 0, User.count

    @request.env["HTTP_REMOTE_USER"] = "testuser"
    get :index

    assert_equal 1, User.count
    assert_equal "testuser", User.last.login
    assert_equal User.last.id, session[:user]
  end

  should 'create a new user even if there is a logged user but the remote user is different' do
    user = create_user('testuser', :email => 'testuser@example.com', :password => 'test', :password_confirmation => 'test')
    user.activate

    login_as user.login


    @request.env["HTTP_REMOTE_USER"] = 'another_user'
    get :index

    assert_equal 2, User.count
    assert_equal "another_user", User.last.login
    assert_equal User.last.id, session[:user]
  end
end
