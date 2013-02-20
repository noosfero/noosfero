require File.dirname(__FILE__) + '/../test_helper'

class PluginTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
  end
  attr_reader :environment

  include Noosfero::Plugin::HotSpot

  should 'keep the list of all loaded subclasses' do
    class Plugin1 < Noosfero::Plugin
    end

    class Plugin2 < Noosfero::Plugin
    end

    assert_includes  Noosfero::Plugin.all, Plugin1.to_s
    assert_includes  Noosfero::Plugin.all, Plugin2.to_s
  end

  should 'returns url to plugin management if plugin has admin_controller' do
    class Plugin1 < Noosfero::Plugin
    end
    File.stubs(:exists?).with(anything).returns(true)

    assert_equal({:controller => 'plugin_test/plugin1_admin', :action => 'index'}, Plugin1.admin_url)
  end

  should 'register its macros in the environment when instantiated' do
    class Plugin1 < Noosfero::Plugin
      def macro_example1(params, inner_html, source)
      end

      def example2(params, inner_html, source)
      end

      def not_macro
      end

      def macro_methods
        ['macro_example1', 'example2']
      end
    end
    
    Environment.macros = {}
    Environment.macros[environment.id] = {}
    macros = Environment.macros[environment.id]
    context = mock()
    context.stubs(:environment).returns(environment)

    plugin_instance = Plugin1.new(context)

    assert_equal plugin_instance, macros['macro_example1']
    assert_equal plugin_instance, macros['example2']
    assert_nil macros['not_macro']
  end

  should 'load_comments return nil by default' do

    class Plugin1 < Noosfero::Plugin; end;

    environment.stubs(:enabled_plugins).returns([Plugin1.to_s])

    profile = fast_create(Profile, :name => 'test profile', :identifier => 'test_profile')
    a = fast_create(Article, :name => 'my article', :profile_id => profile.id)
    assert_nil plugins.dispatch_first(:load_comments, a)
  end

  should 'load_comments return the value defined by plugin' do

    class Plugin1 < Noosfero::Plugin
      def load_comments(page)
        'some value'
      end
    end

    environment.stubs(:enabled_plugins).returns([Plugin1.to_s])

    profile = fast_create(Profile, :name => 'test profile', :identifier => 'test_profile')
    a = fast_create(Article, :name => 'my article', :profile_id => profile.id)
    assert_equal 'some value', plugins.dispatch_first(:load_comments, a)
  end

end
