require_relative '../test_helper'

class BreadcrumbsPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = BreadcrumbsPlugin.new
  end

  should 'has a name' do
    refute BreadcrumbsPlugin.plugin_name.blank?
  end

  should 'has a description' do
    refute BreadcrumbsPlugin.plugin_description.blank?
  end

  should 'add a block' do
    assert_equal [BreadcrumbsPlugin::ContentBreadcrumbsBlock], BreadcrumbsPlugin.extra_blocks.keys
  end

  should 'has stylesheet' do
    assert @plugin.stylesheet?
  end

end
