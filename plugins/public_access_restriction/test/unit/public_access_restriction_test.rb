require 'test_helper'

class PublicAccessRestrictionPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = PublicAccessRestrictionPlugin.new
    @context = mock()
    @plugin.context = @context
    @env = Environment.new
    @context.stubs(:environment).returns(@env)
  end

  should 'not block a common authenticated user' do
    user = fast_create Person
    profile = fast_create Community
    assert ! @plugin.should_block?(user, @env, {}, nil)
    assert ! @plugin.should_block?(user, @env, {controller:'any'}, profile)
    assert ! @plugin.should_block?(user, @env, {controller:'account'}, nil)
    assert ! @plugin.should_block?(user, @env, {controller:'home'}, nil)
  end

  should 'block a unauthenticated user on most controllers' do
    user = nil
    profile = fast_create Community
    assert @plugin.should_block?(user, @env, {controller:'some'}, nil)
    assert @plugin.should_block?(user, @env, {controller:'some'}, profile)
  end

  should 'not block a unauthenticated user on home controller' do
    user = nil
    assert ! @plugin.should_block?(user, @env, {controller:'home'}, nil)
  end

  should 'not block a unauthenticated user on portal profile' do
    user = nil
    profile = fast_create Community
    @env.stubs(:is_portal_community?).returns(profile)
    assert ! @plugin.should_block?(user, @env, {controller:'some'}, profile)
    assert ! @plugin.should_block?(user, @env, {controller:'content_viewer',
              action:'view_page', profile:profile.identifier, page:'some'}, nil)
  end

  should 'not block a unauthenticated user on account controller' do
    user = nil
    assert ! @plugin.should_block?(user, @env, {controller:'account'}, nil)
  end

end
