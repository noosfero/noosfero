require File.dirname(__FILE__) + '/../test_helper'

class PluginManagerTest < Test::Unit::TestCase

  def setup
    @environment = Environment.default
    @controller = mock()
    @controller.stubs(:profile).returns()
    @controller.stubs(:request).returns()
    @controller.stubs(:response).returns()
    @controller.stubs(:environment).returns(@environment)
    @controller.stubs(:params).returns()
    @manager = Noosfero::Plugin::Manager.new(@controller)
  end
  attr_reader :environment
  attr_reader :manager

  should 'return the intersection between environment\'s enabled plugins and system available plugins' do
    class Plugin1 < Noosfero::Plugin; end;
    class Plugin2 < Noosfero::Plugin; end;
    class Plugin3 < Noosfero::Plugin; end;
    class Plugin4 < Noosfero::Plugin; end;
    environment.stubs(:enabled_plugins).returns([Plugin1.to_s, Plugin2.to_s, Plugin4.to_s])
    Noosfero::Plugin.stubs(:all).returns([Plugin1.to_s, Plugin3.to_s, Plugin4.to_s])
    plugins = manager.enabled_plugins.map { |instance| instance.class.to_s }
    assert_equal [Plugin1.to_s, Plugin4.to_s], plugins
  end

  should 'map events to registered plugins' do

    class Noosfero::Plugin
      def random_event
        nil
      end
    end

    class Plugin1 < Noosfero::Plugin
      def random_event
        'Plugin 1 action.'
      end
    end

    class Plugin2 < Noosfero::Plugin
      def random_event
        'Plugin 2 action.'
      end
    end

    environment.stubs(:enabled_plugins).returns([Plugin1.to_s, Plugin2.to_s])

    p1 = Plugin1.new
    p2 = Plugin2.new

    assert_equal [p1.random_event, p2.random_event], manager.map(:random_event)
  end

end

