require File.dirname(__FILE__) + '/../test_helper'

class PluginTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
  end
  attr_reader :environment

  should 'keep the list of all loaded subclasses' do
    class Plugin1 < Noosfero::Plugin
    end

    class Plugin2 < Noosfero::Plugin
    end

    assert_includes  Noosfero::Plugin.all, Plugin1.to_s
    assert_includes  Noosfero::Plugin.all, Plugin1.to_s
  end

  should 'returns url to plugin management if plugin has admin_controller' do
    class Plugin1 < Noosfero::Plugin
    end
    File.stubs(:exists?).with(anything).returns(true)

    assert_equal({:controller => 'plugin_test/plugin1_admin', :action => 'index'}, Plugin1.admin_url)
  end

end
