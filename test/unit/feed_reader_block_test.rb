require_relative "../test_helper"

class FeedReaderBlockTest < ActiveSupport::TestCase

  include DatesHelper

  def setup
    @feed = create(:feed_reader_block)
  end
  attr_reader :feed

  should 'default describe' do
    assert_not_equal Block.description, FeedReaderBlock.description
  end

  should 'have address and limit' do
    assert_respond_to feed, :address
    assert_respond_to feed, :limit
  end

  should 'default value of limit' do
    assert_equal 5, feed.limit
  end

  should 'is editable' do
    assert feed.editable?
  end

  should 'display feed posts from content' do
    feed.feed_items = []
    %w[ last-post second-post first-post ].each do |i|
      feed.feed_items << {:title => i, :link => "http://localhost/#{i}"}
    end
    feed.feed_title = 'Feed for unit tests'
    feed_content = feed.content
    assert_tag_in_string feed_content, :tag => 'h3', :content => 'Feed for unit tests'
    assert_tag_in_string feed_content, :tag => 'a', :attributes => { :href => 'http://localhost/last-post' }, :content => 'last-post'
    assert_tag_in_string feed_content, :tag => 'a', :attributes => { :href => 'http://localhost/second-post' }, :content => 'second-post'
    assert_tag_in_string feed_content, :tag => 'a', :attributes => { :href => 'http://localhost/first-post' }, :content => 'first-post'
  end

  should 'display channel title as title by default' do
    feed.feed_title = 'Feed for unit tests'
    assert_equal 'Feed for unit tests', feed.title
  end

  should 'display default title when hasnt feed_content' do
    assert_equal 'Feed Reader', feed.title
  end

  should 'notice when content not fetched yet' do
    assert_equal'Feed content was not loaded yet', feed.footer
  end

  should 'display last fetched date' do
    now = Time.new(2014,1,1)
    feed.feed_items = ['one', 'two']
    feed.fetched_at = now
    assert_equal "Updated: #{show_date(now)}", feed.footer
  end

  should 'clear feed title and items' do
    feed.feed_items = %w[ last-post second-post first-post ]
    feed.feed_title = 'Feed Test'
    feed.clear
    assert_nil feed.feed_title
    assert_equal [], feed.feed_items
  end

  should 'save! when commit' do
    feed.expects(:save!)
    feed.finish_fetch
  end

  should 'set fetched_at when finishing a fetch' do
    feed.stubs(:save!)
    feed.finish_fetch
    assert_not_nil feed.fetched_at
  end

  should 'have empty fetched_at by default' do
    assert_nil feed.fetched_at
  end

  should 'display the latest post first' do
    %w[ first-post second-post last-post ].each do |i|
      feed.add_item(i, "http://localhost/#{i}", Date.today, "some contet for #{i}")
    end

    assert_equal %w[ last-post second-post first-post ], feed.feed_items.map{|i|i[:title]}
  end

  should 'display only limit posts' do
    feed.limit = 1; feed.save!
    %w[ first-post second-post ].each do |i|
      feed.add_item(i, "http://localhost/#{i}", Date.today, "some contet for #{i}")
    end

    assert_tag_in_string feed.formatted_feed_content, :tag => 'a', :attributes => { :href => 'http://localhost/second-post' }, :content => 'second-post'
    assert_no_tag_in_string feed.formatted_feed_content, :tag => 'a', :attributes => { :href => 'http://localhost/first-post' }, :content => 'first-post'
  end

  should 'have empty error message by default' do
    assert FeedReaderBlock.new.error_message.blank?, 'new feed reader block expected to have empty error message'
  end

  should "display error message as content when it's the case" do
    msg = "there was a problem"
    feed.error_message = msg
    assert_match(msg, feed.content)
  end

  should 'expire after a period' do
    # save current time
    now = Time.now
    expired =  FeedReaderBlock.new
    expired.save
    not_expired = FeedReaderBlock.new
    not_expired.save

    # Noosfero is configured to update feeds every 4 hours
    FeedUpdater.stubs(:update_interval).returns(4.hours)

    # 5 hours ago
    Time.stubs(:now).returns(now  - 5.hours)
    expired.finish_fetch

    # 3 hours ago
    Time.stubs(:now).returns(now - 3.hours)
    not_expired.finish_fetch

    # now one block should be expired and not the other
    Time.stubs(:now).returns(now)
    expired_list = FeedReaderBlock.expired
    assert_includes expired_list, expired
    assert_not_includes expired_list, not_expired
  end

  should 'consider recently-created as expired' do
    # feed is created in setup
    assert_includes FeedReaderBlock.expired, feed
  end

  should 'have an update errors counter' do
    assert_equal 5, FeedReaderBlock.new(:update_errors => 5).update_errors
  end

  should 'have 0 errors by default' do
    assert_equal 0, FeedReaderBlock.new.update_errors
  end

  should 'be disabled by default' do
    assert_equal false, FeedReaderBlock.new.enabled
  end

  should 'be enabled when address is filled' do
    reader = build(:feed_reader_block, :address => 'http://www.example.com/feed')
    assert_equal true, reader.enabled
  end

  should 'be expired when address is updated' do
    reader = build(:feed_reader_block, :address => 'http://www.example.com/feed')
    reader.finish_fetch
    expired_list = FeedReaderBlock.expired
    assert_not_includes expired_list, reader
    reader.address = "http://www.example.com/new-feed"
    reader.save!
    expired_list = FeedReaderBlock.expired
    assert_includes expired_list, reader
  end

  should 'be disabled when address is empty' do
    reader = build(:feed_reader_block, :address => 'http://www.example.com/feed').tap do |f|
      f.enabled = true
    end
    reader.address = nil
    assert_equal false, reader.enabled
  end

  should 're-enable when address is changed' do
    reader = build(:feed_reader_block, :address => 'http://www.example.com/feed')
    reader.enabled = false

    reader.address = 'http://www.example.com/feed'
    assert_equal false, reader.enabled, 'must not enable when setting to the same address'

    reader.address = 'http://www.acme.com/feed'
    assert_equal true, reader.enabled, 'must enable when setting to new address'
  end

  should 'keep enable when address is not changed' do
    reader = build(:feed_reader_block, :address => 'http://www.example.com/feed')
    reader.address = 'http://www.example.com/feed'
    assert_equal true, reader.enabled
  end

end
