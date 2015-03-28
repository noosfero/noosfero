require_relative "../test_helper"

class PluginManagerTest < ActiveSupport::TestCase

  include Noosfero::Plugin::HotSpot

  def setup
    @environment = Environment.default
    @controller = mock()
    @controller.stubs(:profile).returns()
    @controller.stubs(:request).returns()
    @controller.stubs(:response).returns()
    @controller.stubs(:params).returns()
    @manager = Noosfero::Plugin::Manager.new(@environment, @controller)
  end
  attr_reader :environment
  attr_reader :manager

  should 'give access to environment and context' do
    assert_same @environment, @manager.environment
    assert_same @controller, @manager.context
  end

  should 'return the intersection between environment\'s enabled plugins and system available plugins' do
    class Plugin1 < Noosfero::Plugin; end;
    class Plugin2 < Noosfero::Plugin; end;
    class Plugin3 < Noosfero::Plugin; end;
    class Plugin4 < Noosfero::Plugin; end;
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1', 'PluginManagerTest::Plugin2', 'PluginManagerTest::Plugin3', 'PluginManagerTest::Plugin4'])
    environment.stubs(:enabled_plugins).returns([Plugin1.to_s, Plugin2.to_s, Plugin4.to_s])
    Noosfero::Plugin.stubs(:all).returns([Plugin1.to_s, Plugin3.to_s, Plugin4.to_s])
    results = plugins.enabled_plugins.map { |instance| instance.class.to_s }
    assert_equal [Plugin1.to_s, Plugin4.to_s], results
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
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1', 'PluginManagerTest::Plugin2'])

    environment.stubs(:enabled_plugins).returns([Plugin1.to_s, Plugin2.to_s])

    p1 = Plugin1.new
    p2 = Plugin2.new

    assert_equal [p1.random_event, p2.random_event], plugins.dispatch(:random_event)
  end

  should 'dispatch_first method returns the first plugin response if there is many plugins to responde the event' do
    class Noosfero::Plugin
      def random_event
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

    class Plugin3 < Noosfero::Plugin
      def random_event
        'Plugin 3 action.'
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1', 'PluginManagerTest::Plugin2', 'PluginManagerTest::Plugin3'])

    environment.stubs(:enabled_plugins).returns([Plugin1.to_s, Plugin2.to_s, Plugin3.to_s])
    p1 = Plugin1.new

    assert_equal p1.random_event, plugins.dispatch_first(:random_event)
  end

  should 'return the first non-blank result' do
    class Plugin1 < Noosfero::Plugin
      def random_event
      end
    end

    class Plugin2 < Noosfero::Plugin
      def random_event
        'Plugin2'
      end
    end

    class Plugin3 < Noosfero::Plugin
      def random_event
        'Plugin3'
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1', 'PluginManagerTest::Plugin2', 'PluginManagerTest::Plugin3'])

    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)
    environment.enable_plugin(Plugin3.name)

    Plugin3.any_instance.expects(:random_event).never

    assert 'Plugin2', manager.dispatch_first(:random_event)
  end

  should 'returns plugins that returns true to the event' do
    class Plugin1 < Noosfero::Plugin
      def random_event
      end
    end

    class Plugin2 < Noosfero::Plugin
      def random_event
        true
      end
    end

    class Plugin3 < Noosfero::Plugin
      def random_event
        true
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1', 'PluginManagerTest::Plugin2', 'PluginManagerTest::Plugin3'])

    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)
    environment.enable_plugin(Plugin3.name)

    results = manager.fetch_plugins(:random_event)

    assert_includes results, Plugin2
    assert_includes results, Plugin3
  end

  should 'return the first plugin that returns true' do
    class Plugin1 < Noosfero::Plugin
      def random_event
      end
    end

    class Plugin2 < Noosfero::Plugin
      def random_event
        true
      end
    end

    class Plugin3 < Noosfero::Plugin
      def random_event
        true
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1', 'PluginManagerTest::Plugin2', 'PluginManagerTest::Plugin3'])

    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)
    environment.enable_plugin(Plugin3.name)

    Plugin3.any_instance.expects(:random_event).never

    assert_equal Plugin2, manager.fetch_first_plugin(:random_event)
  end

  should 'return nil if missing method is called' do
    class Plugin1 < Noosfero::Plugin
    end
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1'])
    environment.enable_plugin(Plugin1)

    assert_equal nil, @manager.result_for(Plugin1.new, :content_remove_new)
  end

  should 'parse macro' do
    class Plugin1 < Noosfero::Plugin
      def macros
        [Macro1, Macro2]
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1'])

    class Plugin1::Macro1 < Noosfero::Plugin::Macro
      def convert(macro, source)
        macro.gsub('%{name}', 'Macro1')
      end
    end

    class Plugin1::Macro2 < Noosfero::Plugin::Macro
      def convert(macro, source)
        macro.gsub('%{name}', 'Macro2')
      end
    end

    environment.enable_plugin(Plugin1)
    macro = 'My name is %{name}!'

    assert_equal 'My name is Macro1!', manager.parse_macro(Plugin1::Macro1.identifier, macro)
    assert_equal 'My name is Macro2!', manager.parse_macro(Plugin1::Macro2.identifier, macro)
  end

  should 'dispatch event in a pipeline sequence' do
    class Plugin1 < Noosfero::Plugin
      def transform(v1, v2)
        v = 2
        [v1 * v, v2 * v]
      end
    end

    class Plugin2 < Noosfero::Plugin
      def transform(v1, v2)
        v = 5
        [v1 * v, v2 * v]
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1', 'PluginManagerTest::Plugin2'])

    environment.enable_plugin(Plugin1)
    environment.enable_plugin(Plugin2)

    assert_equal [10, 20], manager.pipeline(:transform, 1, 2)
  end

  should 'be able to pipeline with single arguments' do
    class Plugin1 < Noosfero::Plugin
      def transform(value)
        value * 2
      end
    end

    class Plugin2 < Noosfero::Plugin
      def transform(value)
        value * 5
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1', 'PluginManagerTest::Plugin2'])

    environment.enable_plugin(Plugin1)
    environment.enable_plugin(Plugin2)

    assert_equal 10, manager.pipeline(:transform, 1)
  end

  should 'raise if pipeline is broken' do
    class Plugin1 < Noosfero::Plugin
      def transform(v1, v2)
        v = 2
        [v1 * v, v2 * v]
      end
    end

    class Plugin2 < Noosfero::Plugin
      def transform(v1, v2)
        v = 5
        [v1 * v, v2 * v, 666]
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1', 'PluginManagerTest::Plugin2'])

    environment.enable_plugin(Plugin1)
    environment.enable_plugin(Plugin2)

    assert_raise ArgumentError do
      manager.pipeline(:transform, 1, 2)
    end
  end

  should 'filter a property' do
    class Plugin1 < Noosfero::Plugin
      def invalid_numbers(numbers)
        numbers.reject {|n| n%2==0}
      end
    end

    class Plugin2 < Noosfero::Plugin
      def invalid_numbers(numbers)
        numbers.reject {|n| n<=5}
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1', 'PluginManagerTest::Plugin2'])

    environment.enable_plugin(Plugin1)
    environment.enable_plugin(Plugin2)

    assert_equal [7,9], manager.filter(:invalid_numbers, [1,2,3,4,5,6,7,8,9,10])
  end

  should 'only call default if value is blank' do
    class Plugin1 < Noosfero::Plugin
      def find_by_contents asset, scope, query, paginate_options={}, options={}
        {results: [1,2,3]}
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1'])
    environment.enable_plugin(Plugin1)

    Noosfero::Plugin.any_instance.expects(:find_by_contents).never
    @manager.dispatch_first :find_by_contents, :products, environment.products, 'product'
  end

  should 'not event if it is not defined by plugin' do
    class Noosfero::Plugin
      def never_call
        nil
      end
    end
    class Plugin1 < Noosfero::Plugin
      def never_call
        'defined'
      end
    end
    class Plugin2 < Noosfero::Plugin
    end
    Noosfero::Plugin.stubs(:all).returns(['PluginManagerTest::Plugin1', 'PluginManagerTest::Plugin2'])
    environment.enable_plugin(Plugin1)
    environment.enable_plugin(Plugin2)
    plugin1 = @manager.enabled_plugins.detect{ |p| p.is_a? Plugin1 }
    plugin2 = @manager.enabled_plugins.detect{ |p| p.is_a? Plugin2 }

    assert_equal Plugin1, Plugin1.new.method(:never_call).owner
    assert_equal Noosfero::Plugin, Plugin2.new.method(:never_call).owner
    # expects never can't be used as it defines the method
    @manager.expects(:result_for).with(plugin1, :never_call).returns(Plugin1.new.never_call)
    @manager.expects(:result_for).with(plugin2, :never_call).returns(nil)
    @manager.dispatch :never_call
  end

end
