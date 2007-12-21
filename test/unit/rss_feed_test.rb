require File.dirname(__FILE__) + '/../test_helper'

class RssFeedTest < Test::Unit::TestCase

  should 'indicate the correct mime/type' do
    assert_equal 'text/xml', RssFeed.new.mime_type
  end

  should 'store settings in a hash serialized into body field' do
    feed = RssFeed.new
    assert_kind_of Hash, feed.body

    feed.body = {
      :include => :abstract,
      :search => :parent,
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
    assert_match /<title>article 1<\/title>/, rss
    assert_match /<title>article 2<\/title>/, rss
    assert_match /<title>article 3<\/title>/, rss
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
    #feed = RssFeed.new
    #feed.
    flunk 'pending'
  end

  should 'be able to choose search in all articles or in subarticles of parent' do
    flunk 'pending'
  end

  should 'be able to indicate maximum number of items' do
    flunk 'pending'
  end

end
