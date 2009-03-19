require File.dirname(__FILE__) + '/../test_helper'

class FeedHandlerTest < Test::Unit::TestCase

  class FeedContainer
    attr_accessor :limit
    attr_accessor :fetched_at
    attr_accessor :feed_title
    attr_accessor :feed_items
    attr_accessor :address
    def initialize
      self.limit = 5
      self.feed_title = "Feed Container Mocked"
      self.feed_items = []
      self.address = 'test/fixtures/files/feed.xml'
    end
    def add_item(title, link, date, content)
      self.feed_items << title
    end
  end

  def setup
    @handler = FeedHandler.new
    @container = FeedContainer.new
  end
  attr_reader :handler, :container

  should 'fetch feed content' do
    content = handler.fetch(container.address)
    assert_match /<description>Feed content<\/description>/, content
    assert_match /<title>Feed for unit tests<\/title>/, content
  end

  should 'parse feed content' do
    content = ""
    open(container.address) do |s| content = s.read end
    parse = handler.parse(content)
    assert_equal 'Feed for unit tests', parse.title
    assert_equal 'http://localhost/feed-test', parse.link
    assert_equal 'Last POST', parse.items[0].title
  end

  should 'process feed and populate container' do
    handler.process(container)
    assert_equal 'Feed for unit tests', container.feed_title
    assert_equal ["Last POST", "Second POST", "First POST"], container.feed_items
  end

  should 'raise exception when parser nil' do
    handler = FeedHandler.new
    assert_raise FeedHandler::ParseError do
      handler.parse(nil)
    end
  end

  should 'raise exception when parser invalid content' do
    handler = FeedHandler.new
    assert_raise FeedHandler::ParseError do
      handler.parse('<invalid>content</invalid>')
    end
  end

  should 'raise exception when fetch nil' do
    handler = FeedHandler.new
    assert_raise FeedHandler::FetchError do
      handler.fetch(nil)
    end
  end

  should 'raise exception when fetch invalid address' do
    handler = FeedHandler.new
    assert_raise FeedHandler::FetchError do
      handler.fetch('bli://invalid@address')
    end
  end

  should 'save only latest N posts from feed' do
    container.limit = 1
    handler.process(container)
    assert_equal 1, container.feed_items.size
  end

end
