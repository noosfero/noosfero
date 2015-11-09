require 'test_helper'
require_relative '../../controllers/piwik_plugin_admin_controller'

class PiwikPluginAdminControllerTest < ActionController::TestCase

  def setup
    @environment = Environment.default
    user_login = create_admin_user(@environment)
    login_as(user_login)
    @environment.enabled_plugins = ['PiwikPlugin']
    @environment.save!
  end

  should 'access index action' do
    get :index
    assert_template 'index'
    assert_response :success
  end

  should 'update piwik plugin settings' do
    assert_nil @environment.reload.piwik_domain
    assert_nil @environment.reload.piwik_site_id
    post :index, :environment => { :piwik_domain => 'http://something', :piwik_site_id => 10 }
    assert_not_nil @environment.reload.piwik_domain
    assert_not_nil @environment.reload.piwik_site_id
  end

end
