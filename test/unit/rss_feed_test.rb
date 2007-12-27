require File.dirname(__FILE__) + '/../test_helper'

class RssFeedTest < Test::Unit::TestCase

  should 'indicate the correct mime/type' do
    assert_equal 'text/xml', RssFeed.new.mime_type
  end

  should 'store settings in a hash serialized into body field' do
    feed = RssFeed.new
    assert_kind_of Hash, feed.body

    feed.body = {
      :description => :abstract,
      :search => :parent_and_children,
    }
    feed.valid?
    assert !feed.errors.invalid?(:body)
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

    feed = RssFeed.new(:name => 'feed')
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

    feed = RssFeed.new(:name => 'feed')
    feed.profile = profile
    feed.save!
  
    rss = feed.data
    assert_no_match /<item><title>feed<\/title>/, rss
  end

  should 'list recent article from parent article' do
    profile = create_user('testuser').person
    feed = RssFeed.new
    feed.expects(:profile).returns(profile).at_least_once
    array = []
    profile.expects(:recent_documents).returns(array)
    feed.data
  end

  should 'be able to choose to put abstract or entire body on feed' do
    profile = create_user('testuser').person
    a1 = profile.articles.build(:name => 'article 1', :abstract => 'my abstract', :body => 'my text'); a1.save!

    feed = RssFeed.new(:name => 'feed')
    feed.profile = profile
    feed.save!

    rss = feed.data
    assert_match /<description>my abstract<\/description>/, rss
    assert_no_match /<description>my text<\/description>/, rss

    feed.settings[:description] = :body
    rss = feed.data
    assert_match /<description>my text<\/description>/, rss
    assert_no_match /<description>my abstract<\/description>/, rss
  end

  should "be able to search only children of feed's parent" do
    profile = create_user('testuser').person
    a1 = profile.articles.build(:name => 'article 1'); a1.save!
    a2 = profile.articles.build(:name => 'article 2'); a2.save!

    a3 = profile.articles.build(:name => 'article 3'); a3.save!
    a3_1 = a3.children.build(:name => 'article 3.1', :parent => a3, :profile => profile); a3_1.save!
    a3_2 = a3.children.build(:name => 'article 3.2', :parent => a3, :profile => profile); a3_2.save!
    a3_2_1 = a3_2.children.build(:name => 'article 3.2.1', :parent => a3_2, :profile => profile); a3_2_1.save!

    feed = RssFeed.new(:name => 'feed')
    feed.parent = a3
    feed.profile = profile
    feed.settings[:include] = :parent_and_children
    feed.save!

    rss = feed.data
    assert_match /<item><title>article 3<\/title>/, rss
    assert_match /<item><title>article 3\.1<\/title>/, rss
    assert_match /<item><title>article 3\.2<\/title>/, rss
    assert_match /<item><title>article 3\.2\.1<\/title>/, rss

    assert_no_match /<item><title>article 1<\/title>/, rss
    assert_no_match /<item><title>article 2<\/title>/, rss
  end

  should 'be able to indicate maximum number of items' do
    profile = create_user('testuser').person
    a1 = profile.articles.build(:name => 'article 1'); a1.save!
    a2 = profile.articles.build(:name => 'article 2'); a2.save!
    a3 = profile.articles.build(:name => 'article 3'); a3.save!

    feed = RssFeed.new(:name => 'feed')
    feed.profile = profile
    feed.save!

    feed.profile.expects(:recent_documents).with(10).returns([]).once
    feed.data

    feed.settings[:limit] = 5
    feed.profile.expects(:recent_documents).with(5).returns([]).once
    feed.data
  end

  should 'provide proper short description' do
    RssFeed.expects(:==).with(Article).returns(true).at_least_once
    assert_not_equal Article.short_description, RssFeed.short_description
  end

  should 'provide proper description' do
    RssFeed.expects(:==).with(Article).returns(true).at_least_once
    assert_not_equal Article.description, RssFeed.description
  end

end
