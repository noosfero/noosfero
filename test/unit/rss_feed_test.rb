require File.dirname(__FILE__) + '/../test_helper'

class RssFeedTest < Test::Unit::TestCase

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
    assert !feed.errors.invalid?('body')
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

    feed = RssFeed.new(:name => 'testfeed')
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

    feed = RssFeed.new(:name => 'testfeed')
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
    profile.expects(:recent_documents).returns(array)
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
    feed = RssFeed.new(:name => 'testfeed')
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
    blog = Blog.create!(:name => 'blog-test', :profile => profile)
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
    blog = Blog.create!(:name => 'blog-test', :profile => profile)
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
    feed = RssFeed.new(:name => 'testfeed')
    feed.profile = profile
    feed.save!

    profile.environment.expects(:default_hostname).returns('mysite.net').at_least_once

    assert_match "<link>http://mysite.net/testuser</link>", feed.data
  end

  should 'provide link to each article' do
    profile = create_user('testuser').person
    art = profile.articles.build(:name => 'myarticle'); art.save!
    feed = RssFeed.new(:name => 'testfeed')
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

    feed = RssFeed.new(:name => 'testfeed')
    feed.profile = profile
    feed.save!

    feed.profile.expects(:recent_documents).with(10).returns([]).once
    feed.data

    feed.limit = 5
    feed.profile.expects(:recent_documents).with(5).returns([]).once
    feed.data
  end

  should 'limit should only accept integers' do
    feed = RssFeed.new
    feed.limit = 'text'
    feed.valid?
    assert feed.errors.invalid?(:limit)
    feed.limit = 10
    feed.valid?
    assert !feed.errors.invalid?(:limit)
  end

  should 'allow only parent_and_children and all as include setting' do
    feed = RssFeed.new
    feed.include = :something_else
    feed.valid?
    assert feed.errors.invalid?(:include)

    feed.include = 'parent_and_children'
    feed.valid?
    assert !feed.errors.invalid?(:include)

    feed.include = 'all'
    feed.valid?
    assert !feed.errors.invalid?(:include)
  end

  should 'provide proper short description' do
    assert_kind_of String, RssFeed.short_description
  end

  should 'provide proper description' do
    assert_kind_of String, RssFeed.description
  end

  should 'provide the correct icon name' do
    assert_equal 'rss-feed', RssFeed.new.icon_name
  end

  should 'advertise is false before create' do
    profile = create_user('testuser').person
    feed = RssFeed.create!(:name => 'testfeed', :profile => profile)
    assert !feed.advertise?
  end

  should 'can display hits' do
    p = create_user('testuser').person
    a = RssFeed.create!(:name => 'Test article', :profile => p)
    assert_equal false, a.can_display_hits?
  end

  should 'display the referenced body of a PublishedArticle' do
    article = fast_create(Article, :body => 'This is the content of the Sample Article.')
    profile = fast_create(Profile)
    blog = fast_create(Blog, :profile_id => profile.id)
    published_article = PublishedArticle.create!(:reference_article => article, :profile => profile)
    blog.posts << published_article
    feed = RssFeed.new(:parent => blog, :profile => profile)

    assert_match published_article.to_html, feed.data
  end

end
