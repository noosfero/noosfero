require File.dirname(__FILE__) + '/../../../../test/test_helper'

class SocialSharePrivacyPluginTest < ActiveSupport::TestCase

  include NoosferoTestHelper

  def setup
    @plugin = SocialSharePrivacyPlugin.new
  end

  should 'be a noosfero plugin' do
    assert_kind_of Noosfero::Plugin, @plugin
  end

  should 'have name' do
    assert_equal "Social Share Privacy", SocialSharePrivacyPlugin.plugin_name
  end

  should 'have description' do
    assert_equal "A plugin that adds share buttons from other networks.", SocialSharePrivacyPlugin.plugin_description
  end

  should 'have default value for networks setting' do
    @settings = Noosfero::Plugin::Settings.new(Environment.default, SocialSharePrivacyPlugin)
    assert_equal [], @settings.get_setting(:networks)
  end

  should 'return html code for social share privacy buttons' do
    self.stubs(:environment).returns(Environment.default)
    content = @plugin.article_extra_contents(mock())
    assert self.instance_eval(&content)
  end

end
