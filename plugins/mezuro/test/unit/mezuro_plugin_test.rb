require "test_helper"
class MezuroPluginTest < ActiveSupport::TestCase
  
  def setup
    @plugin = MezuroPlugin.new
  end
  
  should 'be a noosfero plugin' do
    assert_kind_of Noosfero::Plugin, @plugin
  end

  should 'have name' do
    assert_equal 'Mezuro', MezuroPlugin.plugin_name
  end

  should 'have description' do
    assert_equal _('A metric analizer plugin.'), MezuroPlugin.plugin_description
  end

  should 'have configuration content type' do
    assert_includes @plugin.content_types, MezuroPlugin::ConfigurationContent
  end

  should 'have project content type' do
    assert_includes @plugin.content_types, MezuroPlugin::ProjectContent
  end

  should 'have stylesheet' do
    assert @plugin.stylesheet?
  end

  should 'list javascript files' do
    assert_equal ['javascripts/results.js', 'javascripts/toogle.js'], @plugin.js_files
  end

end
