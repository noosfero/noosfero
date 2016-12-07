require 'test_helper'

class SectionBlockPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = SectionBlockPlugin.new
  end

  should 'has a name' do
    refute SectionBlockPlugin.plugin_name.blank?
  end

  should 'has a description' do
    refute SectionBlockPlugin.plugin_description.blank?
  end
  
  should 'add a block' do
    assert_equal [SectionBlockPlugin::SectionBlock], SectionBlockPlugin.extra_blocks.keys
  end

  should 'has stylesheet' do
    assert @plugin.stylesheet?
  end

end
