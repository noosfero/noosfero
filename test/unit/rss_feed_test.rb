require_relative "../test_helper"

class RssFeedTest < ActiveSupport::TestCase

  should 'indicate the correct mime/type' do
    assert_equal 'text/xml', RssFeed.new.mime_type
  end

  should 'store settings in a hash serialized into body field' do
    feed = RssFeed.new
    assert_kind_of Hash, feed.body

    feed.body = {
      :feed_item_description => 'abstract',
      :search => 'parent_and_children',
    }
    feed.valid?
    refute feed.errors['body'.to_s].present?
  end

  should 'alias body as "settings"' do
    feed = RssFeed.new
    assert_same feed.body, feed.settings
  end

  should 'list recent articles of profile when top-level' do
    profile = create_user('testuser').person
    a1 = profile.articles.build(:name => 'article 1'); a1.save!
    a2 = profile.articles.build(:name => 'article 2'); a2.save!
    a3 = profile.articles.build(:name => 'article 3'); a3.save!

    feed = build(RssFeed, :name => 'testfeed')
    feed.profile = profile
    feed.save!

    rss = feed.data
    assert_match /<item><title>article 1<\/title>/, rss
    assert_match /<item><title>article 2<\/title>/, rss
    assert_match /<item><title>article 3<\/title>/, rss
  end

  should 'not list self' do
    profile = create_user('testuser').person
    a1 = profile.articles.build(:name => 'article 1'); a1.save!
    a2 = profile.articles.build(:name => 'article 2'); a2.save!
    a3 = profile.articles.build(:name => 'article 3'); a3.save!

    feed = build(RssFeed, :name => 'testfeed')
    feed.profile = profile
    feed.save!

    rss = feed.data
    assert_no_match /<item><title>testfeed<\/title>/, rss
  end

  should 'list recent article from parent article' do
    profile = create_user('testuser').person
    feed = RssFeed.new
    feed.expects(:profile).returns(profile).at_least_once
    array = []
    profile.expects(:last_articles).returns(array)
    feed.data
  end

  should "be able to search only children of feed's parent" do
    profile = create_user('testuser').person
    a1 = profile.articles.build(:name => 'article 1'); a1.save!
    a2 = profile.articles.build(:name => 'article 2'); a2.save!

    a3 = profile.articles.build(:name => 'article 3'); a3.save!
    a3_1 = a3.children.build(:name => 'article 3.1', :parent => a3, :profile => profile); a3_1.save!
    a3_2 = a3.children.build(:name => 'article 3.2', :parent => a3, :profile => profile); a3_2.save!
    a3_2_1 = a3_2.children.build(:name => 'article 3.2.1', :parent => a3_2, :profile => profile); a3_2_1.save!

    a3.reload
    feed = build(RssFeed, :name => 'testfeed')
    feed.parent = a3
    feed.profile = profile
    feed.include = 'parent_and_children'
    feed.save!

    rss = feed.data
    assert_match /<item><title>article 3<\/title>/, rss
    assert_match /<item><title>article 3\.1<\/title>/, rss
    assert_match /<item><title>article 3\.2<\/title>/, rss
    assert_match /<item><title>article 3\.2\.1<\/title>/, rss

    assert_no_match /<item><title>article 1<\/title>/, rss
    assert_no_match /<item><title>article 2<\/title>/, rss
  end

  should 'list blog posts with more recent first and respecting limit' do
    profile = create_user('testuser').person
    blog = create(Blog, :name => 'blog-test', :profile => profile)
    posts = []
    6.times do |i|
      posts << fast_create(TextArticle, :name => "post #{i}", :profile_id => profile.id, :parent_id => blog.id)
    end
    feed = blog.feed
    feed.limit = 5
    feed.save!

    assert_equal [posts[5], posts[4], posts[3],  posts[2], posts[1]], feed.fetch_articles
  end

  should 'list only published posts from blog' do
    profile = create_user('testuser').person
    blog = create(Blog, :name => 'blog-test', :profile => profile)
    posts = []
    5.times do |i|
      posts << fast_create(TextArticle, :name => "post #{i}", :profile_id => profile.id, :parent_id => blog.id)
    end
    posts[0].published = false
    posts[0].save!

    assert_equal [posts[4], posts[3], posts[2], posts[1]], blog.feed.fetch_articles
  end


  should 'provide link to profile' do
    profile = create_user('testuser').person
    feed = build(RssFeed, :name => 'testfeed')
    feed.profile = profile
    feed.save!

    assert_match "<link>http://#{profile.environment.default_hostname}/testuser/homepage</link>", feed.data
  end

  should 'provide link to each article' do
    profile = create_user('testuser').person
    art = profile.articles.build(:name => 'myarticle'); art.save!
    feed = build(RssFeed, :name => 'testfeed')
    feed.profile = profile
    feed.save!

    data = feed.data
    assert_match "<link>http://#{art.profile.environment.default_hostname}/testuser/myarticle</link>", data
    assert_match "<guid>http://#{art.profile.environment.default_hostname}/testuser/myarticle</guid>", data
  end

  should 'be able to indicate maximum number of items' do
    profile = create_user('testuser').person
    a1 = profile.articles.build(:name => 'article 1'); a1.save!
    a2 = profile.articles.build(:name => 'article 2'); a2.save!
    a3 = profile.articles.build(:name => 'article 3'); a3.save!

    feed = build(RssFeed, :name => 'testfeed')
    feed.profile = profile
    feed.save!

    feed.profile.expects(:last_articles).with(10).returns([]).once
    feed.data

    feed.limit = 5
    feed.profile.expects(:last_articles).with(5).returns([]).once
    feed.data
  end

  should 'limit should only accept integers' do
    feed = RssFeed.new
    feed.limit = 'text'
    assert_not_equal 'text', feed.limit
    feed.limit = 10
    assert_equal 10, feed.limit
  end

  should 'allow only parent_and_children and all as include setting' do
    feed = RssFeed.new
    feed.include = :something_else
    feed.valid?
    assert feed.errors[:include.to_s].present?

    feed.include = 'parent_and_children'
    feed.valid?
    refute feed.errors[:include.to_s].present?

    feed.include = 'all'
    feed.valid?
    refute feed.errors[:include.to_s].present?
  end

  should 'provide proper short description' do
    assert_kind_of String, RssFeed.short_description
  end

  should 'provide proper description' do
    assert_kind_of String, RssFeed.description
  end

  should 'provide the correct icon name' do
    assert_equal 'rss-feed', RssFeed.icon_name
  end

  should 'advertise is false before create' do
    profile = create_user('testuser').person
    feed = create(RssFeed, :name => 'testfeed', :profile => profile)
    refute feed.advertise?
  end

  should 'can display hits' do
    p = create_user('testuser').person
    a = create(RssFeed, :name => 'Test article', :profile => p)
    assert_equal false, a.can_display_hits?
  end

  should 'display the referenced body of a article published' do
    article = fast_create(TextileArticle, :body => 'This is the content of the Sample Article.', :profile_id => fast_create(Person).id)
    profile = fast_create(Profile)
    blog = fast_create(Blog, :profile_id => profile.id)
    a = create(ApproveArticle, :name => 'test name', :article => article, :target => profile, :requestor => fast_create(Person))
    a.requestor.stubs(:notification_emails).returns(['random@example.org'])
    a.finish

    published_article = article.class.last
    published_article.parent = blog
    published_article.save

    feed = build(RssFeed, :parent => blog, :profile => profile)

    assert_match "This is the content of the Sample Article", feed.data
  end

  should 'display articles even within a private profile' do
    profile = create_user('testuser').person
    profile.public_profile = false
    profile.save!
    a1 = profile.articles.build(:name => 'article 1'); a1.save!
    a2 = profile.articles.build(:name => 'article 2'); a2.save!
    a3 = profile.articles.build(:name => 'article 3'); a3.save!

    feed = build(RssFeed, :name => 'testfeed')
    feed.profile = profile
    feed.save!

    rss = feed.data
    assert_match /<item><title>article 1<\/title>/, rss
    assert_match /<item><title>article 2<\/title>/, rss
    assert_match /<item><title>article 3<\/title>/, rss
  end

  should 'provide a non-nil to_html' do
    assert_not_nil RssFeed.new.to_html
  end

  should 'include posts from all languages' do
    profile = create_user('testuser').person
    blog = create(Blog, :name => 'blog-test', :profile => profile, :language => nil)
    blog.posts << en_post = fast_create(TextArticle, :name => "English", :profile_id => profile.id, :parent_id => blog.id, :published => true, :language => 'en')
    blog.posts << es_post = fast_create(TextArticle, :name => "Spanish", :profile_id => profile.id, :parent_id => blog.id, :published => true, :language => 'es')

    assert blog.feed.fetch_articles.include?(en_post)
    assert blog.feed.fetch_articles.include?(es_post)
  end

  should 'include only posts from some language' do
    profile = create_user('testuser').person
    blog = create(Blog, :name => 'blog-test', :profile => profile)
    blog.feed.update! :language => 'es'
    blog.posts << en_post = fast_create(TextArticle, :name => "English", :profile_id => profile.id, :parent_id => blog.id, :published => true, :language => 'en')
    blog.posts << es_post = fast_create(TextArticle, :name => "Spanish", :profile_id => profile.id, :parent_id => blog.id, :published => true, :language => 'es')

    assert_equal [es_post], blog.feed.fetch_articles
  end

end
