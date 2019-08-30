# encoding: UTF-8

require_relative "../test_helper"

class TinyMceArticleTest < ActiveSupport::TestCase
  def setup
    super
    @user = User.current = create_user("zezinho")
    @profile = @user.person
  end
  attr_reader :profile

  should "not sanitize target attribute" do
    article = create(TextArticle, name: "open link in new window", body: "open <a href='www.invalid.com' target='_blank'>link</a> in new window", profile: profile)
    assert_tag_in_string article.body, tag: "a", attributes: { target: "_blank" }
  end

  should "not translate & to amp; over times" do
    article = create(TextArticle, name: "link", body: "<a href='www.invalid.com?param1=value&param2=value'>link</a>", profile: profile)
    assert article.save
    assert_no_match(/&amp;amp;/, article.body)
    assert_match(/&amp;/, article.body)
  end

  should "not escape comments from tiny mce article body" do
    article = create(TextArticle, profile: profile, name: "article", abstract: "abstract", body: "the <!-- comment --> article ...")
    assert_equal "the <!-- comment --> article ...", article.body
  end

  should "convert entities characters to UTF-8 instead of ISO-8859-1" do
    article = create(TextArticle, profile: profile, name: "teste " + Time.now.to_s, body: '<a title="inform&#225;tica">link</a>')
    assert(article.body.is_utf8?, "%s expected to be valid UTF-8 content" % article.body.inspect)
  end

  should "remove iframe if it is not from a trusted site" do
    article = create(TextArticle, profile: profile, name: "article", abstract: "abstract", body: "<iframe src='http://anything/videos.ogg'></iframe>")
    assert_equal "", article.body
  end

  should "not mess with <iframe and </iframe if it is from itheora by default" do
    assert_includes Environment.default.trusted_sites_for_iframe, "itheora.org"
    article = create(TextArticle, profile: profile, name: "article", abstract: "abstract", body: "<iframe src='http://itheora.org/demo/index.php?v=example.ogv'></iframe>")
    assert_tag_in_string article.body, tag: "iframe", attributes: { src: "http://itheora.org/demo/index.php?v=example.ogv" }
  end

  should "allow iframe if it is from stream.softwarelivre.org by default" do
    assert_includes Environment.default.trusted_sites_for_iframe, "stream.softwarelivre.org"
    article = create(TextArticle, profile: profile, name: "article", abstract: "abstract", body: "<iframe src='http://stream.softwarelivre.org/fisl10/sites/default/files/videos.ogg'></iframe>")
    assert_tag_in_string article.body, tag: "iframe", attributes: { src: "http://stream.softwarelivre.org/fisl10/sites/default/files/videos.ogg" }
  end

  should "allow iframe if it is from tv.softwarelivre.org by default" do
    assert_includes Environment.default.trusted_sites_for_iframe, "tv.softwarelivre.org"
    article = create(TextArticle, profile: profile, name: "article", abstract: "abstract", body: "<iframe id='player-base' src='http://tv.softwarelivre.org/embed/1170' width='482' height='406' align='right' frameborder='0' scrolling='no'></iframe>")
    assert_tag_in_string article.body, tag: "iframe", attributes: { src: "http://tv.softwarelivre.org/embed/1170", width: "482", height: "406", align: "right", frameborder: "0", scrolling: "no" }
  end

  should "allow iframe if it is from a trusted site" do
    env = Environment.default
    env.trusted_sites_for_iframe = ["avideosite.com"]
    env.save
    assert_includes Environment.default.trusted_sites_for_iframe, "avideosite.com"
    article = create(TextArticle, profile: profile, name: "article", abstract: "abstract", body: "<iframe src='http://avideosite.com/videos.ogg'></iframe>")
    assert_tag_in_string article.body, tag: "iframe", attributes: { src: "http://avideosite.com/videos.ogg" }
  end

  should "remove only the iframe from untrusted site" do
    article = create(TextArticle, profile: profile, name: "article", abstract: "abstract", body: "<iframe src='http://stream.softwarelivre.org/videos.ogg'></iframe><iframe src='http://untrusted_site.com/videos.ogg'></iframe>")
    assert_tag_in_string article.body, tag: "iframe", attributes: { src: "http://stream.softwarelivre.org/videos.ogg" }
    assert_no_tag_in_string article.body, tag: "iframe", attributes: { src: "http://untrusted_site.com/videos.ogg" }
  end

  should "consider first src if there is 2 or more src" do
    assert_includes Environment.default.trusted_sites_for_iframe, "itheora.org"

    article = create(TextArticle, profile: profile, name: "article", abstract: "abstract", body: "<iframe src='http://itheora.org/videos.ogg' src='http://untrusted_site.com/videos.ogg'></iframe>")
    assert_tag_in_string article.body, tag: "iframe", attributes: { src: "http://itheora.org/videos.ogg" }
  end

  should "not sanitize html comments" do
    article = TextArticle.new
    article.body = "<!-- <asdf> << aasdfa >>> --> <h1> Wellformed html code </h1>"
    article.valid?

    assert_match /<!-- .* --> <h1> Wellformed html code <\/h1>/, article.body
  end

  should "not allow XSS on name" do
    article = create(TextArticle, name: 'title with <script>alert("xss")</script>', profile: profile)
    assert_no_match /script/, article.name
  end

  should "not allow XSS on abstract" do
    article = create(TextArticle, name: "test 123", abstract: 'abstract with <script>alert("xss")</script>', profile: profile)
    assert_no_match /script/, article.abstract
  end

  should "notifiable be true" do
    a = fast_create(TextArticle)
    assert a.notifiable?
  end

  should "notify activity on create" do
    ActionTracker::Record.delete_all
    create TextArticle, name: "test", profile_id: profile.id, published: true
    assert_equal 1, ActionTracker::Record.count
  end

  should "not group trackers activity of article's creation" do
    ActionTracker::Record.delete_all
    create TextArticle, name: "bar", profile_id: profile.id, published: true
    create TextArticle, name: "another bar", profile_id: profile.id, published: true
    assert_equal 2, ActionTracker::Record.count
    create TextArticle, name: "another bar 2", profile_id: profile.id, published: true
    assert_equal 3, ActionTracker::Record.count
  end

  should "not update activity on update of an article" do
    ActionTracker::Record.delete_all
    article = create TextArticle, profile_id: profile.id
    time = article.activity.updated_at
    Time.stubs(:now).returns(time + 1.day)
    assert_no_difference "ActionTracker::Record.count" do
      article.name = "foo"
      article.save!
    end
    assert_equal time, article.activity.updated_at
  end

  should "not create trackers activity when updating articles" do
    ActionTracker::Record.delete_all
    a1 = create TextArticle, name: "bar", profile_id: profile.id, published: true
    a2 = create TextArticle, name: "another bar", profile_id: profile.id, published: true
    assert_no_difference "ActionTracker::Record.count" do
      a1.name = "foo"; a1.save!
      a2.name = "another foo"; a2.save!
    end
  end

  should "remove activity when an article is destroyed" do
    ActionTracker::Record.delete_all
    a1 = create TextArticle, name: "bar", profile_id: profile.id, published: true
    a2 = create TextArticle, name: "another bar", profile_id: profile.id, published: true
    assert_difference "ActionTracker::Record.count", -2 do
      a1.destroy
      a2.destroy
    end
  end

  should "the tracker action target be defined as the article on articles'creation in communities" do
    ActionTracker::Record.delete_all
    community = fast_create(Community)
    community.add_member profile
    assert profile.is_member_of?(community)
    article = create TextArticle, name: "test", profile_id: community.id
    assert_equal article, ActionTracker::Record.last.target
  end

  should "the tracker action target be defined as the article on articles'creation in profile" do
    ActionTracker::Record.delete_all
    article = create TextArticle, name: "test", profile_id: profile.id
    assert_equal article, ActionTracker::Record.last.target
  end

  should "not sanitize html5 audio tag on body" do
    article = TextArticle.create!(name: "html5 audio", body: "Audio: <audio controls='controls'><source src='http://example.ogg' type='audio/ogg' />Audio not playing?.</audio>", profile: profile)
    assert_tag_in_string article.body, tag: "audio", attributes: { controls: "controls" }
    assert_tag_in_string article.body, tag: "source", attributes: { src: "http://example.ogg", type: "audio/ogg" }
  end

  should "not sanitize html5 video tag on body" do
    article = TextArticle.create!(name: "html5 video", body: "Video: <video controls='controls' autoplay='autoplay'><source src='http://example.ogv' type='video/ogg' />Video not playing?</video>", profile: profile)
    assert_tag_in_string article.body, tag: "video", attributes: { controls: "controls", autoplay: "autoplay" }
    assert_tag_in_string article.body, tag: "source", attributes: { src: "http://example.ogv", type: "video/ogg" }
  end

  should "not sanitize colspan and rowspan attributes" do
    article = TextArticle.create!(name: "table with colspan and rowspan",
                                  body: "<table colspan='2' rowspan='3'><tr></tr></table>",
                                  profile: profile)
    assert_tag_in_string article.body, tag: "table",
                                       attributes: { colspan: "2", rowspan: "3" }
  end

  should "have can_display_media_panel with default true" do
    a = TextArticle.new
    assert a.can_display_media_panel?
  end

  should "have can_display_blocks with default false" do
    assert !TextArticle.can_display_blocks?
  end
end
