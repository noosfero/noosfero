require_relative '../test_helper'

class CommunityBlockPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = CommunityBlockPlugin.new
  end

  should 'be a noosfero plugin' do
    assert_kind_of Noosfero::Plugin, @plugin
  end

  should 'have name' do
    assert_equal 'Community Block Plugin', CommunityBlockPlugin.plugin_name
  end

  should 'have description' do
    assert_equal "A plugin that adds a block to show community description", CommunityBlockPlugin.plugin_description
  end

  should 'have stylesheet' do
    assert @plugin.stylesheet?
  end

  should "return CommunityBlock in extra_blocks class method" do
    assert  CommunityBlockPlugin.extra_blocks.keys.include?(CommunityBlock)
  end

  should "return false for class method has_admin_url?" do
    assert  !CommunityBlockPlugin.has_admin_url?
  end

end
