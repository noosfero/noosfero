require "test_helper"

class LattesCurriculumPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = LattesCurriculumPlugin.new
  end

  should 'be a noosfero plugin' do
    assert_kind_of Noosfero::Plugin, @plugin
  end

  should 'have name' do
    assert_equal 'Lattes Curriculum Plugin', LattesCurriculumPlugin.plugin_name
  end

  should 'have description' do
    assert_equal _('A plugin that imports the lattes curriculum into the users profiles'), LattesCurriculumPlugin.plugin_description
  end

  should 'have stylesheet' do
    assert @plugin.stylesheet?
  end
end
