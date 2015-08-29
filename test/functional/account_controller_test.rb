require_relative "../test_helper"
require 'account_controller'

class AccountControllerTest < ActionController::TestCase

  all_fixtures

  def teardown
    Thread.current[:enabled_plugins] = nil
  end

  def setup
    @controller = AccountController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    disable_signup_bot_check
  end

  def test_should_login_and_redirect
    post :login, :user => {:login => 'johndoe', :password => 'test'}
    assert session[:user]
    assert_response :redirect
  end

  should 'display notice message if the login fail' do
    @controller.stubs(:logged_in?).returns(false)
    post :login, :user => {:login => 'quire', :password => 'quire'}

    assert session[:notice].include?('Incorrect')
  end

  should 'authenticate on the current environment' do
    User.expects(:authenticate).with('fake', 'fake', is_a(Environment))
    @request.env["HTTP_REFERER"] = '/bli'
    post :login, :user => { :login => 'fake', :password => 'fake' }
  end

  should 'fail login if a user is inactive and show a warning message' do
    user = User.create!(login: 'testuser', email: 'test@email.com', password:'test', password_confirmation:'test', activation_code: nil)
    post :login, :user => { :login => 'testuser', :password => 'test' }

    assert_match 'not activated', session[:notice]
    assert_nil session[:user]
  end

  def test_should_fail_login_and_not_redirect
    @request.env["HTTP_REFERER"] = 'bli'
    post :login, :user => {:login => 'johndoe', :password => 'bad password'}
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_allow_signup
    assert_difference 'User.count' do
      new_user
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'User.count' do
      new_user(:login => nil)
      assert assigns(:user).errors[:login]
      assert_response :success
      assert_nil assigns(:register_pending)
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      new_user(:password => nil)
      assert assigns(:user).errors[:password]
      assert_response :success
      assert_nil assigns(:register_pending)
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      new_user(:password_confirmation => nil)
      assert assigns(:user).errors[:password_confirmation]
      assert_response :success
      assert_nil assigns(:register_pending)
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      new_user(:email => nil)
      assert assigns(:user).errors[:email]
      assert_response :success
      assert_nil assigns(:register_pending)
    end
  end

  def test_shoud_not_save_without_acceptance_of_terms_of_use_on_signup
    assert_no_difference 'User.count' do
      Environment.default.update_attribute(:terms_of_use, 'some terms ...')
      new_user
      assert_response :success
      assert_nil assigns(:register_pending)
    end
  end

  def test_shoud_save_with_acceptance_of_terms_of_use_on_signup
    assert_difference 'User.count' do
      Environment.default.update_attribute(:terms_of_use, 'some terms ...')
      new_user(:terms_accepted => '1')
    end
  end

  def test_should_logout
    login_as :johndoe
    get :logout
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_should_remember_me
    @request.env["HTTP_REFERER"] = '/bli'
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
    assert_nil @response.cookies["auth_token"]
  end

  should 'login with cookie' do
    users(:johndoe).remember_me
    @request.cookies["auth_token"] = cookie_for(:johndoe)
    get :index
    assert @controller.send(:logged_in?)
  end

  should 'fail expired cookie login' do
    users(:johndoe).remember_me
    users(:johndoe).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:johndoe)
    get :index
    refute @controller.send(:logged_in?)
  end

  should 'fail cookie login' do
    users(:johndoe).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :index
    refute @controller.send(:logged_in?)
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
    login_as 'johndoe'
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
    assert assigns(:current_user).authenticated?('blabla')
    assert_equal users(:ze), @controller.send(:current_user)
  end

  should 'input current password correctly to change password' do
    login_as 'ze'
    post :change_password, :current_password => 'wrong', :new_password => 'blabla', :new_password_confirmation => 'blabla'
    assert_response :success
    assert_template 'change_password'
    refute  User.find_by_login('ze').authenticated?('blabla')
    assert_equal users(:ze), @controller.send(:current_user)
  end

  should "not change password when new password and new password confirmation don't match" do
    login_as 'ze'
    post :change_password, :current_password => 'test', :new_password => 'blabla', :new_password_confirmation => 'blibli'
    assert_response :success
    assert_template 'change_password'
    refute assigns(:current_user).authenticated?('blabla')
    refute assigns(:current_user).authenticated?('blibli')
    assert_equal users(:ze), @controller.send(:current_user)
  end

  should 'require login to change password' do
    post :change_password
    assert_redirected_to :controller => 'account', :action => 'login'
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

  should 'respond to forgotten password change request with login' do
    create_user('test')

    post :forgot_password, :value => 'test'
    assert_template 'password_recovery_sent'
  end

  should 'respond to forgotten password change request with email' do
    change = ChangePassword.new
    create_user('test', :email => 'test@localhost.localdomain')

    post :forgot_password, :value => 'test@localhost.localdomain'
    assert_template 'password_recovery_sent'
  end

  should 'use redirect_to parameter on successful login' do
    url = 'http://kernel.org'
    post :login, :return_to => url, :user => {:login => 'ze', :password => 'test'}
    assert_redirected_to url
  end

  should 'provide interface for entering new password' do
    code = 'osidufgiashfkjsadfhkj99999'
    person = create_user('joe').person
    change = ChangePassword.create! code: code, requestor: person

    get :new_password, code: code
    assert_equal change, assigns(:change_password)
  end

  should 'actually change password after entering new password' do
    code = 'osidufgiashfkjsadfhkj99999'
    person = create_user('joe').person
    ChangePassword.create! code: code, requestor: person

    post :new_password, code: code, change_password: { password: 'newpass', password_confirmation: 'newpass' }

    assert_template 'new_password_ok'
  end

  should 'require a valid change_password code' do
    ChangePassword.destroy_all

    get :new_password, :code => 'dontexist'
    assert_response 403
    assert_template 'invalid_change_password_code'
  end

  should 'require password confirmation correctly to enter new password' do
    user = create_user('testuser', :email => 'testuser@example.com', :password => 'test', :password_confirmation => 'test')
    user.activate
    change = ChangePassword.create!(:requestor => user.person)

    post :new_password, :code => change.code, :change_password => { :password => 'onepass', :password_confirmation => 'another_pass' }
    assert_response :success
    assert_template 'new_password'

    refute User.find(user.id).authenticated?('onepass')
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
    assert_difference 'User.count' do
      new_user(:login => 'user1', :email => 'user@example.com')
      assert assigns(:user).valid?
      @controller.stubs(:logged_in?).returns(false)
      new_user(:login => 'user2', :email => 'user@example.com')
      assert assigns(:user).errors[:email]
    end
  end

################################
#                              #
#  Enterprise activation tests #
#                              #
################################

  should 'require login for validation question' do
    get :activation_question, :enterprise_code => 'some_code'

    assert_redirected_to :controller => 'account', :action => 'login'
  end

  should 'report invalid enterprise code on signup' do
    person = create_user('mylogin').person
    login_as(person.identifier)

    get :activation_question, :enterprise_code => 'some_invalid_code'

    assert_template 'invalid_enterprise_code'
  end

  should 'report enterprise already enabled' do
    person = create_user('mylogin').person
    login_as(person.identifier)

    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => true)
    ent.update_attribute(:cnpj, '0'*14)
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    get :activation_question, :enterprise_code => '0123456789'

    assert_template 'already_activated'
  end

  should 'load enterprise from code on for validation question' do
    person = create_user('mylogin').person
    login_as(person.identifier)

    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent')
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    get :activation_question, :enterprise_code => '0123456789'

    assert_equal ent, assigns(:enterprise)
  end

  should 'block enterprises that do not have foundation_year or cnpj' do
    person = create_user('mylogin').person
    login_as(person.identifier)

    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    get :activation_question, :enterprise_code => '0123456789'

    assert_template 'blocked'
  end

  should 'show form to those enterprises that have foundation year' do
    person = create_user('mylogin').person
    login_as(person.identifier)

    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    ent.update_attribute(:foundation_year, 1998)
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    get :activation_question, :enterprise_code => '0123456789'

    assert_template 'activation_question'
  end

  should 'show form to those enterprises that have cnpj' do
    person = create_user('mylogin').person
    login_as(person.identifier)

    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    ent.update_attribute(:cnpj, '0'*14)
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    get :activation_question, :enterprise_code => '0123456789'

    assert_template 'activation_question'
  end

  should 'block those who are blocked' do
    person = create_user('mylogin').person
    login_as(person.identifier)

    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    ent.update_attribute(:foundation_year, 1998)
    ent.block
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    get :activation_question, :enterprise_code => '0123456789'

    assert_template 'blocked'
  end

  should 'put hidden field with enterprise code for answering question' do
    person = create_user('mylogin').person
    login_as(person.identifier)

    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    ent.update_attribute(:foundation_year, 1998)
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    get :activation_question, :enterprise_code => '0123456789'

    assert_tag :tag => 'input', :attributes => { :type => 'hidden', :name => 'enterprise_code', :value => '0123456789'}
  end

  should 'require login for accept terms' do
    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    ent.update_attribute(:foundation_year, 1998)
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    post :accept_terms, :enterprise_code => '0123456789', :answer => '1998'

    assert_redirected_to :controller => 'account', :action => 'login'
  end

  should 'block those who failed to answer the question' do
    person = create_user('mylogin').person
    login_as(person.identifier)

    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    ent.update_attribute(:foundation_year, 1998)
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    post :accept_terms, :enterprise_code => '0123456789', :answer => '1997'

    ent.reload

    assert_nil User.find_by_login('test_user')
    assert ent.blocked?
    assert_template 'blocked'
  end

  should 'show terms of use for enterprise owners' do
    person = create_user('mylogin').person
    login_as(person.identifier)

    env = Environment.default
    env.terms_of_enterprise_use = 'Some terms'
    env.save!

    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    ent.update_attribute(:foundation_year, 1998)
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    post :accept_terms, :enterprise_code => '0123456789', :answer => '1998'

    assert_template 'accept_terms'
    assert_tag :tag => 'div', :content => 'Some terms'
  end

  should 'block who is blocked but directly arrive in the second step' do
    person = create_user('mylogin').person
    login_as(person.identifier)

    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    ent.update_attribute(:foundation_year, 1998)
    ent.block
    ent.save
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    get :accept_terms, :enterprise_code => '0123456789', :answer => 1998

    assert_template 'blocked'
  end

  should 'require login to activate enterprise' do
    env = Environment.default
    env.terms_of_use = 'some terms'
    env.save!
    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    ent.update_attribute(:foundation_year, 1998)
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    post :activate_enterprise, :enterprise_code => '0123456789', :answer => '1998', :terms_accepted => true

    assert_redirected_to :controller => 'account', :action => 'login'
  end

  should 'not activate if user does not accept terms' do
    p = create_user('test_user', :password => 'blih', :password_confirmation => 'blih', :email => 'test@noosfero.com').person
    login_as(p.identifier)

    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    ent.update_attribute(:foundation_year, 1998)
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    post :activate_enterprise, :enterprise_code => '0123456789', :answer => '1998', :terms_accepted => false
    ent.reload

    refute ent.enabled
    assert_not_includes ent.members, p
  end

  should 'activate enterprise and make logged user admin' do
    p = create_user('test_user', :password => 'blih', :password_confirmation => 'blih', :email => 'test@noosfero.com').person
    login_as(p.identifier)

    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    ent.update_attribute(:foundation_year, 1998)
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    post :activate_enterprise, :enterprise_code => '0123456789', :answer => '1998', :terms_accepted => true
    ent.reload

    assert ent.enabled
    assert_includes ent.members, p
  end

  should 'load terms of use for users when creating new users as activate enterprise' do
    person = create_user('mylogin').person
    login_as(person.identifier)

    env = Environment.default
    env.terms_of_use = 'some terms'
    env.save!
    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_ent', :enabled => false)
    ent.update_attribute(:foundation_year, 1998)
    EnterpriseActivation.create! code: '0123456789', enterprise: ent

    post :activate_enterprise, :enterprise_code => '0123456789', :answer => '1998', :terms_accepted => true

    assert_equal 'some terms', assigns(:terms_of_use)
  end

# end of enterprise activation tests

  should 'use the current environment for the template of user' do
    template = create_user('test_template', :email => 'test@bli.com', :password => 'pass', :password_confirmation => 'pass').person
    template.is_template = true
    template.boxes.destroy_all
    template.boxes << Box.new
    template.boxes[0].blocks << Block.new
    template.save!
    env = fast_create(Environment, :name => 'test_env')
    disable_signup_bot_check(env)
    env.settings[:person_template_id] = template.id
    env.save!

    @controller.stubs(:environment).returns(env)

    new_user

    assert_equal 1, assigns(:user).person.boxes.size
    assert_equal 1, assigns(:user).person.boxes[0].blocks.size
  end

  should 'display only templates of the current environment' do
    env2 = fast_create(Environment)

    template1 = fast_create(Person, :name => 'template1', :environment_id => Environment.default.id, :is_template => true)
    template2 = fast_create(Person, :name => 'template2', :environment_id => Environment.default.id, :is_template => true)
    template3 = fast_create(Person, :name => 'template3', :environment_id => env2.id, :is_template => true)

    get :signup
    assert_select '#template-options' do |elements|
      assert_match /template1/, elements[0].to_s
      assert_match /template2/, elements[0].to_s
      assert_no_match /template3/, elements[0].to_s
    end
  end

  should 'render person partial' do
    Environment.any_instance.expects(:signup_person_fields).returns(['contact_phone']).at_least_once
    get :signup
    assert_tag :tag => 'input', :attributes => { :name => "profile_data[contact_phone]" }
  end

  should 'redirect to login when unlogged user tries to logout' do
    logout
    assert_nothing_raised NoMethodError do
      get :logout
      assert_redirected_to :action => 'index', :controller => 'home'
    end
  end

  should 'fill session for new users' do
    post :signup, :user => { :login => 'testuser', :password => '123456', :password_confirmation => '123456', :email => 'testuser@example.com' }, :profile_data => { :organization => 'example.com' }
    assert_equal assigns(:user).session, session
  end

  should 'signup filling in mandatory person fields' do
    Person.any_instance.stubs(:required_fields).returns(['organization'])
    assert_difference 'User.count' do
      post :signup, :user => { :login => 'testuser', :password => '123456', :password_confirmation => '123456', :email => 'testuser@example.com' }, :profile_data => { :organization => 'example.com' }
    end
    assert_equal 'example.com', Person['testuser'].organization
  end

  should "create a new user with image" do
    post :signup, :user => {
      :login => 'testuser', :password => '123456', :password_confirmation => '123456', :email => 'testuser@example.com'
      },
      :profile_data => {
        :organization => 'example.com'
      },
      :file => {
        :image => fixture_file_upload('/files/rails.png', 'image/png')
      }

    assert_redirected_to controller: 'home', action: 'welcome'

    person = Person["testuser"]
    assert_equal "rails.png", person.image.filename
  end

  should 'activate user after signup if environment is set to skip confirmation' do
    env = Environment.default
    env.enable('skip_new_user_email_confirmation')
    env.save!
    new_user(:login => 'activated_user')
    user = User.find_by_login('activated_user')
    assert user.activated?
  end

  should 'redirect to initial page after logout' do
    login_as :johndoe
    get :logout
    assert_nil session[:user]
    assert_redirected_to :controller => 'home', :action => 'index'
  end

  should 'check_valid_name is available on environment' do
    env = fast_create(Environment, :name => 'Environment test')
    @controller.expects(:environment).returns(env).at_least_once
    profile = create_user('mylogin').person
    get :check_valid_name, :identifier => 'mylogin'
    assert_equal 'validated', assigns(:status_class)
  end

  should 'check if url is not available on environment' do
    @controller.expects(:environment).returns(Environment.default).at_least_once
    profile = create_user('mylogin').person
    get :check_valid_name, :identifier => 'mylogin'
    assert_equal 'invalid', assigns(:status_class)
  end

  should 'suggest a list with three possible usernames' do
    profile = create_user('mylogin').person
    get :check_valid_name, :identifier => 'mylogin'

    assert_equal 3, assigns(:suggested_usernames).uniq.size
  end

  should 'check if e-mail is available on environment' do
    env = fast_create(Environment, :name => 'Environment test')
    @controller.expects(:environment).returns(env).at_least_once
    profile = create_user('mylogin', :email => 'mylogin@noosfero.org', :environment_id => fast_create(Environment).id)
    get :check_email, :address => 'mylogin@noosfero.org'
    assert_equal 'validated', assigns(:status_class)
  end

  should 'check if e-mail is not available on environment' do
    env = fast_create(Environment, :name => 'Environment test')
    @controller.expects(:environment).returns(env).at_least_once
    profile = create_user('mylogin', :email => 'mylogin@noosfero.org', :environment_id => env)
    get :check_email, :address => 'mylogin@noosfero.org'
    assert_equal 'invalid', assigns(:status_class)
  end

  should 'merge user data with extra stuff from plugins' do
    class Plugin1 < Noosfero::Plugin
      def user_data_extras
        {:foo => 'bar'}
      end
    end

    class Plugin2 < Noosfero::Plugin
      def user_data_extras
        proc do
          {:test => 5}
        end
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    e = User.find_by_login('ze').environment
    e.enable_plugin(Plugin1.name)
    e.enable_plugin(Plugin2.name)

    login_as 'ze'

    xhr :get, :user_data
    assert_equal User.find_by_login('ze').data_hash(@controller.gravatar_default).merge({ 'foo' => 'bar', 'test' => 5 }), ActiveSupport::JSON.decode(@response.body)
  end

  should 'activate user when activation code is present and correct' do
    user = User.create! :login => 'testuser', :password => 'test123', :password_confirmation => 'test123', :email => 'test@test.org'
    get :activate, :activation_code => user.activation_code
    assert_not_nil assigns(:message)
    assert_response :success
    post :login, :user => {:login => 'testuser', :password => 'test123'}
    assert_not_nil session[:user]
    assert_redirected_to :controller => 'profile_editor', :profile => 'testuser', :action => 'index'
  end

  should 'not activate user when activation code is missing' do
    @request.env["HTTP_REFERER"] = '/bli'
    user = User.create! :login => 'testuser', :password => 'test123', :password_confirmation => 'test123', :email => 'test@test.org'
    get :activate
    assert_nil assigns(:message)
    post :login, :user => {:login => 'testuser', :password => 'test123'}

    assert_match 'not activated', session[:notice]
    assert_nil session[:user]
  end

  should 'not activate user when activation code is incorrect' do
    @request.env["HTTP_REFERER"] = '/bli'
    user = User.create! :login => 'testuser', :password => 'test123', :password_confirmation => 'test123', :email => 'test@test.org'
    get :activate, :activation_code => 'wrongcode'
    assert_nil assigns(:message)
    post :login, :user => {:login => 'testuser', :password => 'test123'}

    assert_match 'not activated', session[:notice]
    assert_nil session[:user]
  end

  should 'be able to upload an image' do
    new_user({}, :profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } })
    assert_not_nil Person.last.image
  end

  should 'not be able to upload an image bigger than max size' do
    Image.any_instance.stubs(:size).returns(Image.attachment_options[:max_size] + 1024)
    new_user({}, :profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } })
    assert_nil Person.last.image
  end

  should 'display error message when image has more than max size' do
    Image.any_instance.stubs(:size).returns(Image.attachment_options[:max_size] + 1024)
    new_user({}, :profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } })
    assert_tag :tag => 'div', :attributes => { :class => 'errorExplanation', :id => 'errorExplanation' }
  end

  should 'not display error message when image has less than max size' do
    Image.any_instance.stubs(:size).returns(Image.attachment_options[:max_size] - 1024)
    new_user({}, :profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } })
    assert_no_tag :tag => 'div', :attributes => { :class => 'errorExplanation', :id => 'errorExplanation' }
  end

  should 'not redirect when some file has errors' do
    Image.any_instance.stubs(:size).returns(Image.attachment_options[:max_size] + 1024)
    new_user({}, :profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } })
    assert_response :success
    assert_template 'signup'
  end

  should 'login after signup when no e-mail confirmation is required' do
    e = Environment.default
    e.enable('skip_new_user_email_confirmation')
    e.save!

    new_user
    assert_response :redirect
    assert_not_nil assigns(:current_user)
  end

  should 'add extra content on signup forms from plugins' do
    class Plugin1 < Noosfero::Plugin
      def signup_extra_contents
        proc {"<strong>Plugin1 text</strong>"}
      end
    end
    class Plugin2 < Noosfero::Plugin
      def signup_extra_contents
        proc {"<strong>Plugin2 text</strong>"}
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    Environment.default.enable_plugin(Plugin1.name)
    Environment.default.enable_plugin(Plugin2.name)

    get :signup

    assert_tag :tag => 'strong', :content => 'Plugin1 text'
    assert_tag :tag => 'strong', :content => 'Plugin2 text'
  end

  should 'login with an alternative authentication defined by plugin' do
    user = create_user
    class Plugin1 < Noosfero::Plugin
    end
    Plugin1.send(:define_method, :alternative_authentication){ user }

    Noosfero::Plugin.stubs(:all).returns([Plugin1.name])
    Environment.default.enable_plugin(Plugin1.name)

    post :login, :user => {:login => "testuser"}

    assert_equal user.login, assigns(:current_user).login
    assert_response :redirect
  end

  should "login with the default autentication if the alternative authentication method doesn't login the user" do
    class Plugin1 < Noosfero::Plugin
      def alternative_authentication
        nil
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name])
    Environment.default.enable_plugin(Plugin1.name)
    post :login, :user => {:login => 'johndoe', :password => 'test'}
    assert session[:user]
    assert_equal 'johndoe', assigns(:current_user).login
    assert_response :redirect
  end

  should "redirect user on signup if a plugin doesn't allow user registration" do
    class TestRegistrationPlugin < Noosfero::Plugin
      def allow_user_registration
        false
      end
    end
    Noosfero::Plugin.stubs(:all).returns([TestRegistrationPlugin.name])
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestRegistrationPlugin.new])

    post :signup, :user => { :login => 'testuser', :password => '123456', :password_confirmation => '123456', :email => 'testuser@example.com' }
    assert_response :redirect
  end

  should "not display the new user button on login page if not allowed by any plugin" do
    class Plugin1 < Noosfero::Plugin
      def allow_user_registration
        false
      end
    end

    class Plugin2 < Noosfero::Plugin
      def allow_user_registration
        true
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([Plugin1.new, Plugin2.new])

    get :login

    assert_no_tag :tag => 'a', :attributes => {:href => '/account/signup'}
  end

  should "redirect user on forgot_password action if a plugin doesn't allow user to recover its password" do
    class TestRegistrationPlugin < Noosfero::Plugin
      def allow_password_recovery
        false
      end
    end
    Noosfero::Plugin.stubs(:all).returns([TestRegistrationPlugin.name])
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestRegistrationPlugin.new])

    #Redirect on get action
    get :forgot_password
    assert_response :redirect

    #Redirect on post action
    post :forgot_password, :value => 'test'
    assert_response :redirect
  end

  should "not display the forgot password button on login page if not allowed by any plugin" do
    class Plugin1 < Noosfero::Plugin
      def allow_password_recovery
        false
      end
    end

    class Plugin2 < Noosfero::Plugin
      def allow_password_recovery
        true
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.new, Plugin2.new])
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([Plugin1.new, Plugin2.new])

    get :login

    assert_no_tag :tag => 'a', :attributes => {:href => '/account/forgot_password'}
  end

  should 'add extra content on login form from plugins' do
    class Plugin1 < Noosfero::Plugin
      def login_extra_contents
        proc {"<strong>Plugin1 text</strong>"}
      end
    end
    class Plugin2 < Noosfero::Plugin
      def login_extra_contents
        proc {"<strong>Plugin2 text</strong>"}
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    Environment.default.enable_plugin(Plugin1.name)
    Environment.default.enable_plugin(Plugin2.name)

    get :login

    assert_tag :tag => 'strong', :content => 'Plugin1 text'
    assert_tag :tag => 'strong', :content => 'Plugin2 text'
  end

  should 'include honeypot in the signup form' do
    get :signup
    assert_tag :tag => /input|textarea/, :attributes => {:id => 'honeypot'}
  end

  should 'not sign in if the honeypot field is filled' do
    Person.any_instance.stubs(:required_fields).returns(['organization'])
    assert_no_difference 'User.count' do
      post :signup, :user => { :login => 'testuser', :password => '123456', :password_confirmation => '123456', :email => 'testuser@example.com' }, :profile_data => { :organization => 'example.com' }, :honeypot => 'something'
    end
    assert @response.body.blank?
  end

  should "Search for state" do
    create_state_and_city

    xhr :get, :search_state, :state_name=>"Rio Grande"

    json_response = ActiveSupport::JSON.decode(@response.body)
    label = json_response[0]['label']

    assert_equal label, "Rio Grande do Sul"
  end

  should "Search for city" do
    create_state_and_city

    xhr :get, :search_cities, :state_name=>"Rio Grande do Sul", :city_name=>"Lavras"

    json_response = ActiveSupport::JSON.decode(@response.body)
    label = json_response[0]['label']
    category =  json_response[0]['category']

    assert_equal category, "Rio Grande do Sul"
    assert_equal label, "Lavras do Sul"
  end

  should 'redirect to welcome page after successful signup if environment configured as so' do
    environment = Environment.default
    environment.redirection_after_signup = 'welcome_page'
    environment.save!
    new_user
    assert_redirected_to :controller => 'home', :action => 'welcome'
  end

  protected

  def new_user(options = {}, extra_options ={})
    data = {:profile_data => person_data}
    if extra_options[:profile_data]
      data[:profile_data].merge! extra_options.delete(:profile_data)
    end
    data.merge! extra_options

    post :signup, { :user => { :login => 'quire',
      :email => 'quire@example.com',
      :password => 'quire',
      :password_confirmation => 'quire'
    }.merge(options)
    }.merge(data)
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end

  def cookie_for(user)
    auth_token users(user).remember_token
  end

  def disable_signup_bot_check(environment = Environment.default)
    environment.min_signup_delay = 0
    environment.save!
  end

  def create_state_and_city
    city = 'Lavras do Sul'
    state = 'Rio Grande do Sul'

    parent_region = fast_create(NationalRegion, :name => state,
                                :national_region_code => '43',
                                :national_region_type_id => NationalRegionType::STATE)

    fast_create(NationalRegion, :name =>  city,
                                :national_region_code => '431150',
                                :national_region_type_id => NationalRegionType::CITY,
                                :parent_national_region_code => parent_region.national_region_code)
  end
end
