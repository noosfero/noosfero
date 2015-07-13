require 'test_helper'

class FooPluginTest < ActiveSupport::TestCase
  def test_foo
    FooPlugin::Bar.create!
  end

  def test_monkey_patch
    Profile.new.bar
  end

  should "respond to new hotspots" do
    plugin = FooPlugin.new

    assert plugin.respond_to?(:foo_plugin_my_hotspot)
    assert plugin.respond_to?(:foo_plugin_tab_title)
  end

  should "other plugin respond to new hotspots" do
    class TestPlugin < Noosfero::Plugin
    end

    plugin = TestPlugin.new

    assert plugin.respond_to?(:foo_plugin_my_hotspot)
    assert plugin.respond_to?(:foo_plugin_tab_title)
  end
end
