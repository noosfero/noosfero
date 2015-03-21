require "test_helper"

class OpenGraphPlugin::PublisherTest < ActiveSupport::TestCase

  def setup
    @actor = create_user.person
    User.current = @actor.user
    @stories = OpenGraphPlugin::Stories::Definitions
    @publisher = OpenGraphPlugin::Publisher.new
    OpenGraphPlugin::Stories.stubs(:publishers).returns([@publisher])
    @publisher.stubs(:context).returns(:open_graph)
    @publisher.stubs(:og_domain).returns('noosfero.net')
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

    blog = Blog.create! profile: @actor, name: 'blog'
    blog_post = TinyMceArticle.new profile: User.current.person, parent: blog, name: 'blah', author: User.current.person
    @publisher.expects(:publish).with(User.current.person, @stories[:create_an_article], @publisher.send(:url_for, blog_post))
    blog_post.save!

    gallery = Gallery.create! name: 'gallery', profile: User.current.person
    image = UploadedFile.new uploaded_data: fixture_file_upload('/files/rails.png', 'image/png'), parent: gallery, profile: User.current.person
    @publisher.expects(:publish).with(User.current.person, @stories[:add_an_image], @publisher.send(:url_for, image, image.url.merge(view: true)))
    image.save!

    document = UploadedFile.new uploaded_data: fixture_file_upload('/files/doctest.en.xhtml', 'text/html'), profile: User.current.person
    @publisher.expects(:publish).with(User.current.person, @stories[:add_a_document], @publisher.send(:url_for, document, document.url.merge(view: true)))
    document.save!

    event = Event.new name: 'event', profile: User.current.person
    @publisher.expects(:publish).with(User.current.person, @stories[:create_an_event], @publisher.send(:url_for, event))
    event.save!

    forum = Forum.create! name: 'forum', profile: User.current.person
    topic = TinyMceArticle.new profile: User.current.person, parent: forum, name: 'blah2', author: User.current.person
    @publisher.expects(:publish).with(User.current.person, @stories[:start_a_discussion], @publisher.send(:url_for, topic, topic.url.merge(og_type: MetadataPlugin.og_types[:forum])))
    topic.save!

    @publisher.expects(:publish).with(@actor, @stories[:make_friendship_with], @publisher.send(:url_for, @other_actor)).twice
    @publisher.expects(:publish).with(@other_actor, @stories[:make_friendship_with], @publisher.send(:url_for, @actor)).twice
    AddFriend.create!(person: @actor, friend: @other_actor).finish
    Friendship.remove_friendship @actor, @other_actor
    # friend verb is groupable
    AddFriend.create!(person: @actor, friend: @other_actor).finish

    @publisher.expects(:publish).with(User.current.person, @stories[:favorite_a_sse_initiative], @publisher.send(:url_for, @enterprise))
    @enterprise.fans << User.current.person

    # active but published as passive
    User.current = @actor.user

    blog_post = TinyMceArticle.new profile: @enterprise, parent: @enterprise.blog, name: 'blah', author: User.current.person
    story = @stories[:announce_news_from_a_sse_initiative]
    @publisher.expects(:publish).with(User.current.person, story, @publisher.send(:passive_url_for, blog_post, nil, story))
    blog_post.save!

    # passive
    User.current = @other_actor.user

    # fan
    blog_post = TinyMceArticle.new profile: @enterprise, parent: @enterprise.blog, name: 'blah2', author: User.current.person
    story = @stories[:announce_news_from_a_sse_initiative]
    @publisher.expects(:publish).with(@actor, story, 'http://noosfero.net/coop/blog/blah2')
    blog_post.save!
    # member
    blog_post = TinyMceArticle.new profile: @myenterprise, parent: @myenterprise.blog, name: 'blah2', author: User.current.person
    story = @stories[:announce_news_from_a_sse_initiative]
    @publisher.expects(:publish).with(@actor, story, 'http://noosfero.net/mycoop/blog/blah2')
    blog_post.save!

    blog_post = TinyMceArticle.new profile: @community, parent: @community.blog, name: 'blah', author: User.current.person
    story = @stories[:announce_news_from_a_community]
    @publisher.expects(:publish).with(@actor, story, 'http://noosfero.net/comm/blog/blah')
    blog_post.save!
  end

end
