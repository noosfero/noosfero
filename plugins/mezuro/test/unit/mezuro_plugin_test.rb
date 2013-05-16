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

  should 'have stylesheet' do
    assert @plugin.stylesheet?
  end

end
