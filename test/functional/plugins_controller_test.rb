require_relative "../test_helper"
require 'plugins_controller'

# Re-raise errors caught by the controller.
class PluginsController; def rescue_action(e) raise e end; end

class PluginsControllerTest < ActionController::TestCase

  all_fixtures
  def setup
    @controller = PluginsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @environment = Environment.default
    login_as(create_admin_user(@environment))
  end
  attr_reader :environment

  should 'list system active plugins' do
    class Plugin1 < Noosfero::Plugin
      class << self
        def plugin_name
        "Plugin1"
        end
        def plugin_description
          "This plugin is from hell!"
        end
      end
    end

    class Plugin2 < Noosfero::Plugin
      class << self
        def plugin_name
        "Plugin2"
        end
        def plugin_description
          "This plugin is from heaven!"
        end
      end
    end

    Noosfero::Plugin.stubs(:all).returns([Plugin1.to_s, Plugin2.to_s])

    get :index

    assert_tag :tag => 'td', :content => /#{Plugin1.plugin_name}/
    assert_tag :tag => 'td', :content => /#{Plugin1.plugin_description}/
    assert_tag :tag => 'td', :content => /#{Plugin2.plugin_name}/
    assert_tag :tag => 'td', :content => /#{Plugin2.plugin_description}/
  end

  should 'enable or disable plugins' do
    assert_not_equal ['Plugin1'], environment.enabled_plugins
    post :update, :environment => { :enabled_plugins => ['Plugin1']}
    environment.reload
    assert_equal ['Plugin1'], environment.enabled_plugins
  end

end
