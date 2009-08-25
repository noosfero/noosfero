require File.dirname(__FILE__) + '/../test_helper'

class FeedHandlerTest < Test::Unit::TestCase

  def setup
    @handler = FeedHandler.new
    @container = FeedReaderBlock.create!(:box_id => 99999, :address => 'test/fixtures/files/feed.xml')
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
    assert_equivalent ["First POST", "Second POST", "Last POST"], container.feed_items.map {|item| item[:title]}
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

  should 'clear the container before processing' do
    container.expects(:clear)
    handler.process(container)
  end

  should 'finish_fetch after processing' do
    container.expects(:finish_fetch)
    handler.process(container)
  end

  should 'identifies itself as noosfero user agent' do
    handler = FeedHandler.new
    handler.expects(:open).with('http://site.org/feed.xml', {"User-Agent" => "Noosfero/#{Noosfero::VERSION}"}, anything).returns('bli content')
    assert_equal 'bli content', handler.fetch('http://site.org/feed.xml')
  end

end
