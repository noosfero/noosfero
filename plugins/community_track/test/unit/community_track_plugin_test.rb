require_relative '../test_helper'

class CommunityTrackPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = CommunityTrackPlugin.new
    @profile = fast_create(Community)
    @params = {}
    @context = mock
    @context.stubs(:kind_of?).returns(CmsController)
    @context.stubs(:profile).returns(@profile)
    @context.stubs(:params).returns(@params)
    @plugin.stubs(:context).returns(@context)
  end

  attr_reader :profile, :params, :context

  should 'has name' do
    assert CommunityTrackPlugin.plugin_name
  end

  should 'describe yourself' do
    assert CommunityTrackPlugin.plugin_description
  end

  should 'has stylesheet' do
    assert @plugin.stylesheet?
  end

  should 'return Track as a content type if profile is a community' do
    assert_includes @plugin.content_types, CommunityTrackPlugin::Track
  end

  should 'do not return Track as a content type if profile is not a community' do
    context.stubs(:profile).returns(Organization.new)
    assert_not_includes @plugin.content_types, CommunityTrackPlugin::Track
  end

  should 'do not return Track as a content type if there is a parent' do
    parent = fast_create(Blog, :profile_id => profile.id)
    params[:parent_id] = parent.id
    assert_not_includes @plugin.content_types, CommunityTrackPlugin::Track
  end

  should 'return Step as a content type if parent is a Track' do
    parent = fast_create(CommunityTrackPlugin::Track, :profile_id => profile.id)
    params[:parent_id] = parent.id
    assert_includes @plugin.content_types, CommunityTrackPlugin::Step
  end

  should 'do not return Step as a content type if parent is not a Track' do
    parent = fast_create(Blog, :profile_id => profile.id)
    params[:parent_id] = parent.id
    assert_not_includes @plugin.content_types, CommunityTrackPlugin::Step
  end

  should 'return Track and Step as a content type if context has no params' do
    parent = fast_create(Blog, :profile_id => profile.id)
    context.expects(:respond_to?).with(:params).returns(false)
    assert_equivalent [CommunityTrackPlugin::Step, CommunityTrackPlugin::Track], @plugin.content_types
  end

  should 'return Track and Step as a content type if params is nil' do
    parent = fast_create(Blog, :profile_id => profile.id)
    context.stubs(:params).returns(nil)
    assert_equivalent [CommunityTrackPlugin::Step, CommunityTrackPlugin::Track], @plugin.content_types
  end

  should 'return track card as an extra block' do
    assert_includes CommunityTrackPlugin.extra_blocks, CommunityTrackPlugin::TrackListBlock
  end

  should 'return true at content_remove_new if page is a track' do
    assert @plugin.content_remove_new(CommunityTrackPlugin::Track.new)
  end

  should 'return false at content_remove_new if page is not a track' do
    refute @plugin.content_remove_new(CommunityTrackPlugin::Step.new)
    refute @plugin.content_remove_new(Article.new)
  end

end
