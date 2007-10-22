require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  all_fixtures

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_login_and_redirect
    post :login, :login => 'johndoe', :password => 'test'
    assert session[:user]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :login, :login => 'johndoe', :password => 'bad password'
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_allow_signup
    assert_difference User, :count do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference User, :count do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference User, :count do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference User, :count do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference User, :count do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end

  def test_shoud_not_save_without_acceptance_of_terms_of_use_on_signup
    assert_no_difference User, :count do
      Environment.default.update_attributes(:terms_of_use => 'some terms ...')
      create_user
      assert_response :success
    end
  end

  def test_shoud_save_with_acceptance_of_terms_of_use_on_signup
    assert_difference User, :count do
      Environment.default.update_attributes(:terms_of_use => 'some terms ...')      
      create_user(:terms_accepted => '1')
      assert_response :redirect
    end
  end

  def test_should_logout
    login_as :johndoe
    get :logout
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_should_remember_me
    post :login, :login => 'johndoe', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :login, :login => 'johndoe', :password => 'test', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    login_as :johndoe
    get :logout
    assert_equal @response.cookies["auth_token"], []
  end

  # "remember_me" feature is disabled; uncommend this if it is enabled again.
  # def test_should_login_with_cookie
  #   users(:johndoe).remember_me
  #   @request.cookies["auth_token"] = cookie_for(:johndoe)
  #   get :index
  #   assert @controller.send(:logged_in?)
  # end

  def test_should_fail_expired_cookie_login
    users(:johndoe).remember_me
    users(:johndoe).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:johndoe)
    get :index
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:johndoe).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :index
    assert !@controller.send(:logged_in?)
  end

  def test_should_display_anonymous_user_options
    get :index
    assert_template 'index_anonymous'
  end

  def test_should_display_logged_in_user_options
    login_as 'johndoe'
    get :index
    assert_template 'index'
  end

  def test_should_display_change_password_screen
    get :change_password
    assert_response :success
    assert_template 'change_password'
    assert_tag :tag => 'input', :attributes => { :name => 'current_password' }
    assert_tag :tag => 'input', :attributes => { :name => 'new_password' }
    assert_tag :tag => 'input', :attributes => { :name => 'new_password_confirmation' }
  end

  def test_should_be_able_to_change_password
    login_as 'ze'
    post :change_password, :current_password => 'test', :new_password => 'blabla', :new_password_confirmation => 'blabla'
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert User.find_by_login('ze').authenticated?('blabla')
    assert_equal users(:ze), @controller.send(:current_user)
  end

  should 'input current password correctly to change password' do
    login_as 'ze'
    post :change_password, :current_password => 'wrong', :new_password => 'blabla', :new_password_confirmation => 'blabla'
    assert_response :success
    assert_template 'change_password'
    assert ! User.find_by_login('ze').authenticated?('blabla')
    assert_equal users(:ze), @controller.send(:current_user)
  end

  should 'provide a "I forget my password" link at the login page' do
    get :login
    assert_tag :tag => 'a', :attributes => {
      :href => '/account/forgot_password'
    }
  end

  should 'provide a "forgot my password" form' do
    get :forgot_password
    assert_response :success
  end

  should 'respond to forgotten password change request' do
    change = ChangePassword.new
    ChangePassword.expects(:new).with('login' => 'test', 'email' => 'test@localhost.localdomain').returns(change)
    change.expects(:save!).returns(true)

    post :forgot_password, :change_password => { :login => 'test', :email => 'test@localhost.localdomain' }
    assert_template 'password_recovery_sent'
  end

  should 'provide interface for entering new password' do
    change = ChangePassword.new
    ChangePassword.expects(:find_by_code).with('osidufgiashfkjsadfhkj99999').returns(change)
    person = mock
    person.stubs(:identifier).returns('joe')
    change.stubs(:requestor).returns(person)

    get :new_password, :code => 'osidufgiashfkjsadfhkj99999'
    assert_equal change, assigns(:change_password)
  end

  should 'actually change password after entering new password' do
    change = ChangePassword.new
    ChangePassword.expects(:find_by_code).with('osidufgiashfkjsadfhkj99999').returns(change)

    requestor = mock
    requestor.stubs(:identifier).returns('joe')
    change.stubs(:requestor).returns(requestor)
    change.expects(:update_attributes!).with({'password' => 'newpass', 'password_confirmation' => 'newpass'})
    change.expects(:finish)

    post :new_password, :code => 'osidufgiashfkjsadfhkj99999', :change_password => { :password => 'newpass', :password_confirmation => 'newpass' }

    assert_template 'new_password_ok'
  end

  should 'require a valid change_password code' do
    ChangePassword.destroy_all

    get :new_password, :code => 'dontexist'
    assert_response 403
    assert_template 'invalid_change_password_code'
  end

  should 'require password confirmation correctly to enter new pasword' do
    user = User.create!(:login => 'testuser', :email => 'testuser@example.com', :password => 'test', :password_confirmation => 'test')
    change = ChangePassword.create!(:login => 'testuser', :email => 'testuser@example.com')

    post :new_password, :code => change.code, :change_password => { :password => 'onepass', :password_confirmation => 'another_pass' }
    assert_response :success
    assert_template 'new_password'

    assert !User.find(user.id).authenticated?('onepass')
  end

  protected
    def create_user(options = {})
      post :signup, :user => { :login => 'quire', :email => 'quire@example.com', 
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
    
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
