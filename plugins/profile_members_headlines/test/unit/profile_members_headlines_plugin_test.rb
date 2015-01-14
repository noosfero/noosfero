require 'test_helper'

class ProfileMembersHeadlinesPluginTest < ActiveSupport::TestCase

  include Noosfero::Plugin::HotSpot

  def setup
    @environment = fast_create(Environment)
    @environment.enable_plugin(ProfileMembersHeadlinesPlugin)
  end
  attr_accessor :environment

  should 'has a name' do
    assert_not_equal Noosfero::Plugin.plugin_name, ProfileMembersHeadlinesPlugin.plugin_name
  end

  should 'describe itself' do
    assert_not_equal Noosfero::Plugin.plugin_description, ProfileMembersHeadlinesPlugin.plugin_description
  end

  should 'return ProfileMembersHeadlinesBlock in extra_blocks class method' do
    assert ProfileMembersHeadlinesPlugin.extra_blocks.keys.include?(ProfileMembersHeadlinesBlock)
  end

  should 'ProfileMembersHeadlinesBlock not available for environment' do
    assert_not_includes plugins.dispatch(:extra_blocks, :type => Environment), ProfileMembersHeadlinesBlock
  end

  should 'ProfileMembersHeadlinesBlock not available for people' do
    assert_not_includes plugins.dispatch(:extra_blocks, :type => Person), ProfileMembersHeadlinesBlock
  end

  should "ProfileMembersHeadlinesBlock be available for community" do
    assert_includes plugins.dispatch(:extra_blocks, :type => Community), ProfileMembersHeadlinesBlock
  end

  should 'has stylesheet' do
    assert ProfileMembersHeadlinesPlugin.new.stylesheet?
  end

end
