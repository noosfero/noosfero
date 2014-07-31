require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/social_share_privacy_plugin_admin_controller'

# Re-raise errors caught by the controller.
class SocialSharePrivacyPluginAdminController; def rescue_action(e) raise e end; end

class SocialSharePrivacyPluginAdminControllerTest < ActionController::TestCase

  def setup
    @environment = Environment.default
    @profile = create_user('profile').person
    @environment.add_admin(@profile)
    login_as(@profile.identifier)
  end

  attr_reader :environment

  should 'list networks not selected available in alphabetic order' do
    Noosfero::Plugin::Settings.new(environment, SocialSharePrivacyPlugin, :networks => ['gplus']).save!
    @controller.stubs(:social_share_privacy_networks).returns(['gplus', 'twitter', 'facebook'])
    get :index
    assert_equal ['facebook', 'twitter'], assigns(:available_networks)
  end

  should 'list networks selected in order' do
    Noosfero::Plugin::Settings.new(environment, SocialSharePrivacyPlugin, :networks => ['gplus', 'buffer']).save!
    get :index
    assert_equal ['gplus', 'buffer'], assigns(:settings).networks
  end

  should 'save social networks buttons settings' do
    post :index, :settings => {:networks => ['facebook', 'gplus']}
    @settings = Noosfero::Plugin::Settings.new(environment.reload, SocialSharePrivacyPlugin)
    assert_equal ['facebook', 'gplus'], @settings.settings[:networks]
  end

  should 'remove all buttons if none selected' do
    Noosfero::Plugin::Settings.new(environment, SocialSharePrivacyPlugin, :networks => ['twitter', 'gplus', 'buffer']).save!
    post :index, :settings => {:networks => ['']}
    @settings = Noosfero::Plugin::Settings.new(environment.reload, SocialSharePrivacyPlugin)
    assert_equal [], @settings.settings[:networks]
  end

  should 'ignore unknown networks' do
    post :index, :settings => {:networks => ['orkut']}
    @settings = Noosfero::Plugin::Settings.new(environment.reload, SocialSharePrivacyPlugin)
    assert_equal [], @settings.settings[:networks]
  end

  should 'redirect to index after save' do
    post :index
    assert_redirected_to :controller => 'plugins', :action => 'index'
  end
end
