require_relative "../test_helper"

class FeedWriterTest < ActiveSupport::TestCase

  should 'generate feeds' do
    articles = []
    profile = fast_create(:profile, :identifier => "tagger")
    articles << fast_create(:article, :name => 'text 1', :slug => 'text-1', :path => 'text-1', :profile_id => profile.id)
    articles << fast_create(:article, :name => 'text 2', :slug => 'text-2', :path => 'text-2', :profile_id => profile.id) 
    writer = FeedWriter.new

    feed = writer.write(articles)
    assert_match('text 1', feed)
    assert_match('/tagger/' + articles.first.slug, feed)
  end

  should 'generate feed with a gallery' do
    articles = []
    profile = fast_create(:profile, :identifier => "tagger")
    articles << fast_create(:gallery, :name => 'my pics', :profile_id => profile.id)
    writer = FeedWriter.new

    feed = writer.write(articles)
    assert_match('my pics', feed)
  end

  should 'use title, link and description' do
    writer = FeedWriter.new
    rss = writer.write([], :title => "my title", :description => "my description", :link => "http://example.com/")
    assert_match("my title", rss)
    assert_match("my description", rss)
    assert_match("http://example.com/", rss)
  end

end

