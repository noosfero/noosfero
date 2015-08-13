require 'test_helper'

class ContainerBlockPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = ContainerBlockPlugin.new
  end

  should 'has a name' do
    refute ContainerBlockPlugin.plugin_name.blank?
  end

  should 'has a description' do
    refute ContainerBlockPlugin.plugin_description.blank?
  end
  
  should 'add a block' do
    assert_equal [ContainerBlockPlugin::ContainerBlock], ContainerBlockPlugin.extra_blocks.keys
  end

  should 'has stylesheet' do
    assert @plugin.stylesheet?
  end

end
