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

  should 'not block a unauthenticated user on public_access_restriction plugin public_page controller' do
    user = nil
    assert ! @plugin.should_block?(user, @env, {controller:'public_access_restriction_plugin_public_page'}, nil)
  end

  should 'display public page if profile says so' do
    profile = fast_create(Organization)
    settings = { public_access_restriction_plugin: { show_public_page: true } }
    Organization.any_instance.stubs(:data).returns(settings)
    assert @plugin.should_display_public_page?(profile: profile.identifier)
  end

  should 'not display public page if profile does not say so' do
    profile = fast_create(Organization)
    settings = { public_access_restriction_plugin: { show_public_page: false } }
    Organization.any_instance.stubs(:data).returns(settings)
    refute @plugin.should_display_public_page?(profile: profile.identifier)
  end

  should 'not display public page if there is no profile' do
    refute @plugin.should_display_public_page?(profile: nil)
  end

end
