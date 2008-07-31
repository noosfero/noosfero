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

  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  def test_should_login_and_redirect
    post :login, :user => {:login => 'johndoe', :password => 'test'}
    assert session[:user]
    assert_response :redirect
  end

  should 'redirect to user control panel on login' do
    u = create_user
    post :login, :user => {:login => 'quire', :password => 'quire'}

    assert_redirected_to :controller => 'profile_editor', :action => 'index', :profile => 'quire'
  end

  def test_should_fail_login_and_not_redirect
    @request.env["HTTP_REFERER"] = 'bli'
    post :login, :user => {:login => 'johndoe', :password => 'bad password'}
    assert_nil session[:user]
    assert_response :redirect
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
    post :login, :user => {:login => 'johndoe', :password => 'test'}, :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :login, :user => {:login => 'johndoe', :password => 'test'}, :remember_me => "0"
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
    person.stubs(:name).returns('Joe')
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

  should 'display login popup' do
    get :login_popup
    assert_template 'login'
    assert_no_tag :tag => "body" # e.g. no layout
  end

  should 'display logout popup' do
    get :logout_popup
    assert_template 'logout_popup'
    assert_no_tag :tag => "body" # e.g. no layout
  end

  should 'restrict multiple users with the same e-mail' do
    assert_difference User, :count do
      create_user(:login => 'user1', :email => 'user@example.com')
      assert assigns(:user).valid?
      create_user(:login => 'user2', :email => 'user@example.com')
      assert assigns(:user).errors.on(:email)
    end
  end

  should 'correct redirect after login' do
    post :login, :user => {:login => 'johndoe', :password => 'test'}
    assert_redirected_to :controller => 'profile_editor'
  end

################################
#                              #
#  Enterprise activation tests #
#                              #
################################

  should 'report invalid enterprise code on signup' do
    EnterpriseActivation.expects(:find_by_code).with('some_invalid_code').returns(nil).at_least_once

    get :activation_question, :enterprise_code => 'some_invalid_code'

    assert_template 'invalid_enterprise_code'
  end

  should 'report enterprise already enabled' do
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent', :cnpj => '0'*14, :enabled => true)
    task = mock
    task.expects(:enterprise).returns(ent).at_least_once
    EnterpriseActivation.expects(:find_by_code).with('0123456789').returns(task).at_least_once

    get :activation_question, :enterprise_code => '0123456789'

    assert_template 'already_activated'
  end

  should 'load enterprise from code on for validation question' do
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent')
    
    task = mock
    task.expects(:enterprise).returns(ent).at_least_once
    EnterpriseActivation.expects(:find_by_code).with('0123456789').returns(task).at_least_once

    get :activation_question, :enterprise_code => '0123456789'

    assert_equal ent, assigns(:enterprise)
  end

  should 'block enterprises that do not have foundation_year or cnpj' do
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    
    task = mock
    task.expects(:enterprise).returns(ent).at_least_once
    EnterpriseActivation.expects(:find_by_code).with('0123456789').returns(task).at_least_once

    get :activation_question, :enterprise_code => '0123456789'

    assert_template 'blocked'
  end

  should 'show form to those enterprises that have foundation year' do
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent', :foundation_year => 1998, :enabled => false)

    task = mock
    task.expects(:enterprise).returns(ent).at_least_once
    EnterpriseActivation.expects(:find_by_code).with('0123456789').returns(task).at_least_once

    get :activation_question, :enterprise_code => '0123456789'

    assert_template 'activation_question'
  end

  should 'show form to those enterprises that have cnpj' do
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent', :cnpj => '0'*14, :enabled => false)

    task = mock
    task.expects(:enterprise).returns(ent).at_least_once
    EnterpriseActivation.expects(:find_by_code).with('0123456789').returns(task).at_least_once

    get :activation_question, :enterprise_code => '0123456789'

    assert_template 'activation_question'
  end

  should 'block those who are blocked' do
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent', :foundation_year => '1998', :enabled => false)
    ent.block

    task = mock
    task.expects(:enterprise).returns(ent).at_least_once
    EnterpriseActivation.expects(:find_by_code).with('0123456789').returns(task).at_least_once

    get :activation_question, :enterprise_code => '0123456789'

    assert_template 'blocked'
  end

  should 'block those who failed to answer the question' do
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent', :foundation_year => 1998, :enabled => false)

    task = mock
    task.expects(:enterprise).returns(ent).at_least_once
    EnterpriseActivation.expects(:find_by_code).with('0123456789').returns(task).at_least_once

    post :accept_terms, :enterprise_code => '0123456789', :answer => '1997'

    ent.reload

    assert_nil User.find_by_login('test_user')
    assert ent.blocked?
    assert_template 'blocked'
  end

  should 'show term of use for enterprise owners' do
    env = Environment.default
    env.terms_of_enterprise_use = 'Some terms'
    env.save!

    post :accept_terms, :enterprise_code => '0123456789', :answer => '1998'

    assert_template 'accept_terms'
    assert_tag :tag => 'div', :content => 'Some terms'
  end

  should 'not activate if user does not accept terms' do
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent', :foundation_year => 1998, :enabled => false)
    p = User.create!(:login => 'test_user', :password => 'blih', :password_confirmation => 'blih', :email => 'test@noosfero.com').person
    login_as(p.identifier)

    task = EnterpriseActivation.create!(:enterprise => ent)
    EnterpriseActivation.expects(:find_by_code).with('0123456789').returns(task).at_least_once

    post :activate_enterprise, :enterprise_code => '0123456789', :answer => '1998', :terms_accepted => false
    ent.reload

    assert !ent.enabled
    assert_not_includes ent.members, p
  end

  should 'activate enterprise and make user admin' do
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent', :foundation_year => 1998, :enabled => false)
    p = User.create!(:login => 'test_user', :password => 'blih', :password_confirmation => 'blih', :email => 'test@noosfero.com').person
    login_as(p.identifier)

    task = EnterpriseActivation.create!(:enterprise => ent)
    EnterpriseActivation.expects(:find_by_code).with('0123456789').returns(task).at_least_once

    post :activate_enterprise, :enterprise_code => '0123456789', :answer => '1998', :terms_accepted => true
    ent.reload

    assert ent.enabled
    assert_includes ent.members, p
  end

  should 'put hidden field with enterprise code for answering question' do
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent', :foundation_year => 1998, :enabled => false)

    task = mock
    task.expects(:enterprise).returns(ent).at_least_once
    EnterpriseActivation.expects(:find_by_code).with('0123456789').returns(task).at_least_once

    get :activation_question, :enterprise_code => '0123456789'

    assert_tag :tag => 'input', :attributes => { :type => 'hidden', :name => 'enterprise_code', :value => '0123456789'}
  end

# end of enterprise activation tests

  should 'not be able to signup while inverse captcha field filled' do
    assert_no_difference User, :count do
      create_user({}, @controller.icaptcha_field => 'bli@bla.email.foo')
    end
  end

  should 'render inverse captcha field' do
    get :signup
    assert_tag :tag => 'input', :attributes => { :type => 'text', :name => @controller.icaptcha_field }
  end

  protected
    def create_user(options = {}, extra_options ={})
      post :signup, { :user => { :login => 'quire',
                                 :email => 'quire@example.com',
                                 :password => 'quire',
                                 :password_confirmation => 'quire'
                              }.merge(options)
                    }.merge(extra_options)
    end

    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end

    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
