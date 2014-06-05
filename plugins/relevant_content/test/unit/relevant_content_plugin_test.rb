require File.dirname(__FILE__) + '/../test_helper'

class RelevantContentPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = RelevantContentPlugin.new
  end

  should 'be a noosfero plugin' do
    assert_kind_of Noosfero::Plugin, @plugin
  end

  should 'have name' do
    assert_equal 'Relevant Content Plugin', RelevantContentPlugin.plugin_name
  end

  should 'have description' do
    assert_equal  _("A plugin that lists the most accessed, most commented, most liked and most disliked contents."), RelevantContentPlugin.plugin_description
  end

  should 'have stylesheet' do
    assert @plugin.stylesheet?
  end

  should "return RelevantContentBlock in extra_blocks class method" do
    assert  RelevantContentPlugin.extra_blocks.keys.include?(RelevantContentPlugin::RelevantContentBlock)
  end

end
