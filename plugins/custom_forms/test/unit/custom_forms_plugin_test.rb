require 'test_helper'

class CustomFormsPluginTest < ActiveSupport::TestCase

  def setup
    Environment.default.enable_plugin('CustomFormsPlugin')
    @community = fast_create Community
    @person = fast_create Person
    @enterprise = fast_create Enterprise
  end
  attr_reader :community, :person, :enterprise

  should 'extra blocks not available for environment' do
    assert_not_includes Environment.default.available_blocks(person), CustomFormsPlugin::PollsBlock
    assert_not_includes Environment.default.available_blocks(person), CustomFormsPlugin::SurveyBlock
  end

  should 'plugin extra block available for communities, person and enterprise' do
    CustomFormsPlugin.extra_blocks.each do |block|
      assert_equal block[1][:type][0].to_s, "Person"
      assert_equal block[1][:type][1].to_s, "Community"
      assert_equal block[1][:type][2].to_s, "Enterprise"
    end
  end

  should 'extra blocks available for communities, person and enterprise' do
    assert_includes community.available_blocks(person), CustomFormsPlugin::PollsBlock
    assert_includes community.available_blocks(person), CustomFormsPlugin::SurveyBlock

    assert_includes person.available_blocks(person), CustomFormsPlugin::PollsBlock
    assert_includes person.available_blocks(person), CustomFormsPlugin::SurveyBlock

    assert_includes enterprise.available_blocks(person), CustomFormsPlugin::PollsBlock
    assert_includes enterprise.available_blocks(person), CustomFormsPlugin::SurveyBlock
  end

end
