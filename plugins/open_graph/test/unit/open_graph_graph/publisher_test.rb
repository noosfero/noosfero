require "test_helper"

class OpenGraphPlugin::PublisherTest < ActiveSupport::TestCase

  include OpenGraphPlugin::UrlHelper

  def setup
    @actor = create_user.person
    User.current = @actor.user
    @publisher = OpenGraphPlugin::Publisher.new
    OpenGraphPlugin::Stories.stubs(:publishers).returns([@publisher])
    # for MetadataPlugin::UrlHelper#og_url_for
    stubs(:og_domain).returns('noosfero.net')
    OpenGraphPlugin::Activity.any_instance.stubs(:og_domain).returns('noosfero.net')
  end

  should "publish only tracked stuff" do
    @other_actor = create_user.person

    @myenterprise = @actor.environment.enterprises.create! name: 'mycoop', identifier: 'mycoop'
    @myenterprise.add_member @actor
    @enterprise = @actor.environment.enterprises.create! name: 'coop', identifier: 'coop'
    # the original domain from open_graph should be used
    @enterprise.domains.create! name: 'customdomain.com'

    @community = @actor.environment.communities.create! name: 'comm', identifier: 'comm', closed: false

    @actor.update_attributes!({
      open_graph_settings: {
        activity_track_enabled: "true",
        enterprise_track_enabled: "true",
        community_track_enabled: "true",
      },
      open_graph_activity_track_configs_attributes: {
        0 => { tracker_id: @actor.id, object_type: 'blog_post', },
        1 => { tracker_id: @actor.id, object_type: 'gallery_image', },
        2 => { tracker_id: @actor.id, object_type: 'uploaded_file', },
        3 => { tracker_id: @actor.id, object_type: 'event', },
        4 => { tracker_id: @actor.id, object_type: 'forum', },
        5 => { tracker_id: @actor.id, object_type: 'friend', },
        6 => { tracker_id: @actor.id, object_type: 'favorite_enterprise', },
      },
      open_graph_enterprise_profiles_ids: "#{@enterprise.id}",
      open_graph_community_profiles_ids: "#{@community.id}",
    })
    @other_actor.update_attributes! open_graph_settings: { activity_track_enabled: "true", },
      open_graph_activity_track_configs_attributes: { 0 => { tracker_id: @other_actor.id, object_type: 'friend', }, }

    # active
    User.current = @actor.user
    user = User.current.person

    blog = Blog.create! profile: user, name: 'blog'
    blog_post = TinyMceArticle.create! profile: user, parent: blog, name: 'blah', author: user
    assert_last_activity user, :create_an_article, url_for(blog_post)

    gallery = Gallery.create! name: 'gallery', profile: user
    image = UploadedFile.create! uploaded_data: fixture_file_upload('/files/rails.png', 'image/png'), parent: gallery, profile: user
    assert_last_activity user, :add_an_image, url_for(image, image.url.merge(view: true))

    document = UploadedFile.create! uploaded_data: fixture_file_upload('/files/doctest.en.xhtml', 'text/html'), profile: user
    assert_last_activity user, :add_a_document, url_for(document, document.url.merge(view: true))

    event = Event.create! name: 'event', profile: user
    assert_last_activity user, :create_an_event, url_for(event)

    forum = Forum.create! name: 'forum', profile: user
    topic = TinyMceArticle.create! profile: user, parent: forum, name: 'blah2', author: user
    assert_last_activity user, :start_a_discussion, url_for(topic, topic.url.merge(og_type: MetadataPlugin.og_types[:forum]))

    AddFriend.create!(person: user, friend: @other_actor).finish
    #assert_last_activity user, :make_friendship_with, url_for(@other_actor)
    Friendship.remove_friendship user, @other_actor
    # friend verb is groupable
    AddFriend.create!(person: user, friend: @other_actor).finish
    #assert_last_activity @other_actor, :make_friendship_with, url_for(user)

    @enterprise.fans << user
    assert_last_activity user, :favorite_a_sse_initiative, url_for(@enterprise)

    # active but published as passive
    User.current = @actor.user
    user = User.current.person

    blog_post = TinyMceArticle.create! profile: @enterprise, parent: @enterprise.blog, name: 'blah', author: user
    story = :announce_news_from_a_sse_initiative
    assert_last_activity user, story, passive_url_for(blog_post, nil, OpenGraphPlugin::Stories::Definitions[story])

    # passive
    User.current = @other_actor.user
    user = User.current.person

    # fan
    blog_post = TinyMceArticle.create! profile: @enterprise, parent: @enterprise.blog, name: 'blah2', author: user
    assert_last_activity user, :announce_news_from_a_sse_initiative, 'http://noosfero.net/coop/blog/blah2'
    # member
    blog_post = TinyMceArticle.create! profile: @myenterprise, parent: @myenterprise.blog, name: 'blah2', author: user
    assert_last_activity user, :announce_news_from_a_sse_initiative, 'http://noosfero.net/mycoop/blog/blah2'

    blog_post = TinyMceArticle.create! profile: @community, parent: @community.blog, name: 'blah', author: user
    assert_last_activity user, :announce_news_from_a_community, 'http://noosfero.net/comm/blog/blah'
  end

  protected

  def assert_activity activity, actor, story, object_data_url
    assert_equal actor, activity.actor, actor
    assert_equal story.to_s, activity.story
    assert_equal object_data_url, activity.object_data_url
  end

  def assert_last_activity actor, story, object_data_url
    a = OpenGraphPlugin::Activity.order('id DESC').first
    assert_activity a, actor, story, object_data_url
  end

end
