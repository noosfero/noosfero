require_relative "../test_helper"

class FeedHandlerTest < ActiveSupport::TestCase

  def setup
    @handler = FeedHandler.new
    @container = nil
  end
  attr_reader :handler
  def container
    @container ||= create(:feed_reader_block)
  end

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

  should 'finish fetch after processing' do
    container.expects(:finish_fetch)
    handler.process(container)
  end

  should 'finish fetch even in case of crash' do
    container.expects(:clear).raises(Exception.new("crash"))
    container.expects(:finish_fetch)
    handler.process(container)
  end

  should 'identifies itself as noosfero user agent' do
    handler.expects(:open).with('http://site.org/feed.xml', {"User-Agent" => "Noosfero/#{Noosfero::VERSION}"}, anything).returns('bli content')
    assert_equal 'bli content', handler.fetch('http://site.org/feed.xml')
  end

  [:external_feed, :feed_reader_block].each do |container_class|

    should "reset the errors count after a successfull run (#{container_class})" do
      container = create(container_class, :update_errors => 1, :address => Rails.root.join('test/fixtures/files/feed.xml'))
      handler.expects(:actually_process_container).with(container)
      handler.process(container)
      assert_equal 0, container.update_errors
    end

    should "set error message and disable in case of errors (#{container_class})" do
      FeedHandler.stubs(:max_errors).returns(4)

      container = create(container_class)
      handler.stubs(:actually_process_container).with(container).raises(Exception.new("crash"))

      # in the first 4 errors, we are ok
      4.times { handler.process(container) }
      refute container.error_message.blank?, 'should set the error message for the first <max_errors> errors (%s)' % container_class
      assert container.enabled, 'must keep container enabled during the first <max_errors> errors (%s)' % container_class

      # 5 errors it too much
      handler.process(container)
      refute container.error_message.blank?, 'must set error message in container after <max_errors> errors (%s)' % container_class
      refute container.enabled, 'must disable continer after <max_errors> errors (%s)' % container_class
    end

    should "reenable after <disabled_period> (#{container_class})" do
      FeedHandler.stubs(:max_errors).returns(4)

      container = create(container_class)
      handler.stubs(:actually_process_container).with(container).raises(Exception.new("crash"))
      # exceeds max_errors
      5.times { handler.process(container) }

      # after disabled period, tries to process the container again
      handler.stubs(:actually_process_container).with(container)
      container.stubs(:only_once).returns(false)
      last_error = Time.now
      Time.stubs(:now).returns(last_error + FeedHandler.disabled_period + 1.second)
      handler.expects(:actually_process_container).with(container)
      container.expects(:finish_fetch)
      handler.process(container)

      assert container.enabled, 'must reenable container after <disabled_period> (%s)' % container_class
    end
  end

  should 'not crash even when finish fetch fails' do
    container.stubs(:finish_fetch).raises(Exception.new("crash"))
    assert_nothing_raised do
      handler.process(container)
    end
  end

end
