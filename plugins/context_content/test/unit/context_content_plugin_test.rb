require 'test_helper'

class ContextContentPluginTest < ActiveSupport::TestCase

  include Noosfero::Plugin::HotSpot

  def setup
    @environment = fast_create(Environment)
    @environment.enable_plugin(ContextContentPlugin)
  end

  attr_reader :environment

  should 'has a name' do
    assert_not_equal Noosfero::Plugin.plugin_name, ContextContentPlugin.plugin_name
  end

  should 'describe itself' do
    assert_not_equal Noosfero::Plugin.plugin_description, ContextContentPlugin.plugin_description
  end

  should 'return ContextContentBlock in extra_blocks class method' do
    assert ContextContentPlugin.extra_blocks.keys.include?(ContextContentPlugin::ContextContentBlock)
  end

  should 'return false for class method has_admin_url?' do
    assert  !ContextContentPlugin.has_admin_url?
  end

  should 'ContextContentBlock not available for environment' do
    assert_not_includes plugins.dispatch(:extra_blocks, :type => Environment), ContextContentPlugin::ContextContentBlock
  end

  should 'ContextContentBlock available for community' do
    assert_includes plugins.dispatch(:extra_blocks, :type => Community), ContextContentPlugin::ContextContentBlock
  end

  should 'has stylesheet' do
    assert ContextContentPlugin.new.stylesheet?
  end

  [Person, Community, Enterprise].each do |klass|
    should "ContextContentBlock be available for #{klass.name}" do
      assert_includes plugins.dispatch(:extra_blocks, :type => klass), ContextContentPlugin::ContextContentBlock
    end
  end

end
