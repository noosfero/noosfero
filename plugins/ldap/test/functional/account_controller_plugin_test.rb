require_relative '../test_helper'

class AccountControllerPluginTest < ActionController::TestCase

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @environment = Environment.default
    @environment.enabled_plugins = ['LdapPlugin']
    @ldap_config = load_ldap_config
    @environment.ldap_plugin= @ldap_config['server'] unless @ldap_config.nil?
    @environment.save!
  end

  should 'not authenticate user if its not a local user or a ldap user' do
    post :login, :user => {:login => 'someuser', :password => 'somepass'}
    assert_nil session[:user]
  end

  should 'diplay not logged message if the user is not a local user or a ldap user' do
    post :login, :user => {:login => 'someuser', :password => 'somepass'}
    assert_equal 'Incorrect username or password', session[:notice]
  end

  should 'authenticate user if its a local user but is not a ldap user' do
    user = create_user('testuser', :email => 'testuser@example.com', :password => 'test', :password_confirmation => 'test')
    user.activate
    post :login, :user => {:login => 'testuser', :password => 'test'}
    assert session[:user]
  end

  should 'display required fields on user login' do
    @environment.custom_person_fields = {"contact_phone"=>{"required"=>"true", "signup"=>"false", "active"=>"true"}}
    @environment.save
    get :login
    assert_tag(:input, :attributes => {:id => 'profile_data_contact_phone'})
  end

  if ldap_configured?

    should 'authenticate an existing noosfero user with ldap and loggin' do
      user = create_user(@ldap_config['user']['login'], :email => 'testuser@example.com', :password => 'test', :password_confirmation => 'test')
      user.activate
      count = User.count
      post :login, :user => @ldap_config['user']
      assert session[:user]
      assert_equal count, User.count
    end

    should 'login and create a new noosfero user if ldap authentication works properly' do
      count = User.count
      post :login, :user => @ldap_config['user']
      assert session[:user]
      assert_equal count + 1, User.count
    end

    should 'login on ldap if required fields are defined' do
      count = User.count
      @environment.custom_person_fields = {"contact_phone"=>{"required"=>"true", "signup"=>"false", "active"=>"true"}}
      @environment.save
      post :login, :user => @ldap_config['user'], :profile_data => {:contact_phone => '11111111'}
      assert session[:user]
    end

    should 'not login on ldap if required fields are not defined' do
      @environment.custom_person_fields = {"contact_phone"=>{"required"=>"true", "signup"=>"false", "active"=>"true"}}
      @environment.save
      post :login, :user => @ldap_config['user']
      assert_nil session[:user]
    end

    should 'authenticate user if its not a local user but is a ldap user' do
      post :login, :user => @ldap_config['user']
      assert session[:user]
    end

  else
    puts LDAP_SERVER_ERROR_MESSAGE
  end

end
