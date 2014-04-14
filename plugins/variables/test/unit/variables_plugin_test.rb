require 'test_helper'

class VariablesPluginTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
    @plugin = VariablesPlugin.new
  end

  attr_reader :environment, :plugin

  should 'have a name' do
    assert_not_equal Noosfero::Plugin.plugin_name, VariablesPlugin::plugin_name
  end

  should 'describe yourself' do
    assert_not_equal Noosfero::Plugin.plugin_description, VariablesPlugin::plugin_description
  end

end
