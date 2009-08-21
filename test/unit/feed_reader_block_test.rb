require File.dirname(__FILE__) + '/../test_helper'

class FeedReaderBlockTest < ActiveSupport::TestCase

  include DatesHelper

  def setup
    @feed = FeedReaderBlock.new
    @fetched_at = Time.now
    @feed.fetched_at = @fetched_at
    @feed.save!
  end
  attr_reader :feed, :fetched_at

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
    feed.feed_items = ['one', 'two']
    assert_equal "Updated: #{show_date(@fetched_at)}", feed.footer
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



end
