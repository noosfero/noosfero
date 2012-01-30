require "test_helper"
class MezuroPluginTest < Test::Unit::TestCase
  
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

  should 'have project content type' do
    assert_equal MezuroPlugin::ProjectContent, @plugin.content_types
  end

  should 'have stylesheet' do
    assert @plugin.stylesheet?
  end

  should 'list javascript files' do
    assert_equal ['javascripts/results.js', 'javascripts/toogle.js'], @plugin.js_files
  end

end