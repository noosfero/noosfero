require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/ldap_plugin_admin_controller'

# Re-raise errors caught by the controller.
class LdapPluginAdminController; def rescue_action(e) raise e end; end

class LdapPluginAdminControllerTest < ActionController::TestCase

  def setup
    @environment = Environment.default
    user_login = create_admin_user(@environment)
    login_as(user_login)
    @admin = User[user_login].person
    @environment.enabled_plugins = ['LdapPlugin']
    @environment.ldap_plugin_host="http://somehost"
    @environment.save!
  end

  attr_accessor :admin

  should 'access index action' do
    get :index
    assert_template 'index'
    assert_response :success
  end

  should 'update ldap successfully display a message successfully' do
    @environment.ldap_plugin_host = nil
    @environment.save
    assert_nil @environment.ldap_plugin_host
    post :update, :environment => { :ldap_plugin_host => 'http://something' }
    assert_equal 'Ldap configuration updated successfully.', @request.session[:notice]
  end

  should 'wrong ldap update display a message unsuccessfully' do
    @environment.ldap_plugin_host = nil
    @environment.save
    assert_nil @environment.ldap_plugin_host
    post :update, :environment => { :ldap_plugin_host => '' }
    assert_equal 'Ldap configuration could not be saved.', @request.session[:notice]
  end

  should 'update ldap successfully render index template' do
    post :update, :environment => { :ldap_plugin_host => 'http://something' }

    assert_template 'index'
  end

  should 'update ldap unsuccessfully render index template' do
    post :update, :environment => { :ldap_plugin_port => '3434' }

    assert_template 'index'
  end

  should 'update ldap host' do
    @environment.ldap_plugin_host = nil
    @environment.save
    assert_nil @environment.ldap_plugin_host
    post :update, :environment => { :ldap_plugin_host => 'http://something' }

    @environment.reload
    assert_not_nil @environment.ldap_plugin_host
  end

  should 'update ldap port' do
    post :update, :environment => { :ldap_plugin_port => '245' }

    @environment.reload
    assert_not_nil @environment.ldap_plugin_port
  end

  should 'update ldap account' do
    assert_nil @environment.ldap_plugin_account
    post :update, :environment => { :ldap_plugin_account => 'uid=sector,ou=Service,ou=corp,dc=company,dc=com,dc=br' }

    @environment.reload
    assert_not_nil @environment.ldap_plugin_account
  end

  should 'update ldap acccount_password' do
    assert_nil @environment.ldap_plugin_account_password
    post :update, :environment => { :ldap_plugin_account_password => 'password' }

    @environment.reload
    assert_not_nil @environment.ldap_plugin_account_password
  end

  should 'update ldap base_dn' do
    assert_nil @environment.ldap_plugin_base_dn
    post :update, :environment => { :ldap_plugin_base_dn => 'dc=company,dc=com,dc=br' }

    @environment.reload
    assert_not_nil @environment.ldap_plugin_base_dn
  end

  should 'update ldap attr_login' do
    assert_nil @environment.ldap_plugin_attr_login
    post :update, :environment => { :ldap_plugin_attr_login => 'uid' }

    @environment.reload
    assert_not_nil @environment.ldap_plugin_attr_login
  end

  should 'update ldap attr_mail' do
    assert_nil @environment.ldap_plugin_attr_mail
    post :update, :environment => { :ldap_plugin_attr_mail => 'test@noosfero.com' }

    @environment.reload
    assert_not_nil @environment.ldap_plugin_attr_mail
  end

  should 'update ldap onthefly_register' do
    post :update, :environment => { :ldap_plugin_onthefly_register => '1' }

    @environment.reload
    assert_not_nil @environment.ldap_plugin_onthefly_register
  end

  should 'update ldap filter' do
    assert_nil @environment.ldap_plugin_filter
    post :update, :environment => { :ldap_plugin_filter => 'test' }

    @environment.reload
    assert_not_nil @environment.ldap_plugin_filter
  end

  should 'update ldap tls' do
    post :update, :environment => { :ldap_plugin_tls => '1' }

    @environment.reload
    assert_not_nil @environment.ldap_plugin_tls
  end

  should 'have a field to manage the host' do
    get :index

    assert_tag :tag => 'input', :attributes => {:id => 'environment_ldap_plugin_host'}
  end

  should 'have a field to manage the port' do
    get :index

    assert_tag :tag => 'input', :attributes => {:id => 'environment_ldap_plugin_port'}
  end

  should 'have a field to manage the account' do
    get :index

    assert_tag :tag => 'input', :attributes => {:id => 'environment_ldap_plugin_account'}
  end

  should 'have a field to manage the account_password' do
    get :index

    assert_tag :tag => 'input', :attributes => {:id => 'environment_ldap_plugin_account_password'}
  end

  should 'have a field to manage the base_dn' do
    get :index

    assert_tag :tag => 'input', :attributes => {:id => 'environment_ldap_plugin_base_dn'}
  end

  should 'have a field to manage the attr_login' do
    get :index

    assert_tag :tag => 'input', :attributes => {:id => 'environment_ldap_plugin_attr_login'}
  end

  should 'have a field to manage the attr_fullname' do
    get :index

    assert_tag :tag => 'input', :attributes => {:id => 'environment_ldap_plugin_attr_fullname'}
  end

  should 'have a field to manage the attr_mail' do
    get :index

    assert_tag :tag => 'input', :attributes => {:id => 'environment_ldap_plugin_attr_mail'}
  end

  should 'have a field to manage the onthefly_register' do
    get :index

    assert_tag :tag => 'input', :attributes => {:id => 'environment_ldap_plugin_onthefly_register'}
  end

  should 'have a field to manage the filter' do
    get :index

    assert_tag :tag => 'input', :attributes => {:id => 'environment_ldap_plugin_filter'}
  end

  should 'have a field to manage the tls' do
    get :index

    assert_tag :tag => 'input', :attributes => {:id => 'environment_ldap_plugin_tls'}
  end

end
