require_relative "../test_helper"

class ExternalFeedTest < ActiveSupport::TestCase

  should 'require blog' do
    e = ExternalFeed.new
    e.valid?
    assert e.errors[:blog_id].present?
    e.blog = create_blog
    e.valid?
    assert e.errors[:blog_id].blank?
  end

  should 'belong to blog' do
    blog = create_blog
    e = build(:external_feed, :blog => blog)
    assert_equal blog, e.blog
  end

  should 'not add same item twice' do
    blog = create_blog
    e = create(:external_feed, blog: blog)
    assert e.add_item('Article title', 'http://orig.link.invalid', Time.now, 'Content for external post')
    refute e.add_item('Article title', 'http://orig.link.invalid', Time.now, 'Content for external post')
    assert_equal 1, e.blog.posts.size
  end

  should 'do nothing when clear' do
    assert_respond_to ExternalFeed.new, :clear
  end

  should 'not limit' do
    assert_equal 0, ExternalFeed.new.limit
  end

  should 'disable external feed if fetch only once on finish fetch' do
    e = build(:external_feed, :only_once => true, :enabled => true)
    e.stubs(:save!)
    e.finish_fetch
    assert_equal false, e.enabled
  end

  should 'not disable after finish fetch if there are errors' do
    e = build(:external_feed, :only_once => true, :update_errors => 1)
    e.stubs(:save!)
    e.finish_fetch
    assert_equal true, e.enabled
  end

  should 'be enabled by default' do
    assert ExternalFeed.new.enabled
  end

  should 'add items to blog as posts' do
    handler = FeedHandler.new
    blog = create_blog
    e = create(:external_feed, blog: blog)
    handler.process(e)
    assert_equal ["Last POST", "Second POST", "First POST"], e.blog.posts.map{|i| i.title}
  end

  should 'require address if enabled' do
    e = build(ExternalFeed, :enabled => true, :address => nil)
    refute e.valid?
    assert e.errors[:address].present?
  end

  should 'not require address if disabled' do
    e = build(ExternalFeed, :enabled => false, :address => nil)
    e.valid?
    assert e.errors[:address].blank?
  end

  should 'list enabled external feeds' do
    e1 = fast_create(:external_feed, :enabled => true)
    e2 = fast_create(:external_feed, :enabled => false)
    assert_includes ExternalFeed.enabled, e1
    assert_not_includes ExternalFeed.enabled, e2
  end

  should 'have an empty error message by default' do
    assert ExternalFeed.new.error_message.blank?, 'new external feed must have empty error message'
  end

  should 'have empty fetch date by default' do
    assert_nil ExternalFeed.new.fetched_at
  end

  should 'set fetch date when finishing fetch' do
    feed = ExternalFeed.new
    feed.stubs(:save!)
    feed.finish_fetch
    assert_not_nil feed.fetched_at
  end

  should 'have empty fetch when change address' do
    feed = ExternalFeed.new
    feed.stubs(:save!)
    feed.address = 'http://localhost/example_feed'
    feed.finish_fetch
    assert_not_nil feed.fetched_at
    feed.address = 'http://localhost/other_example_feed'
    assert_nil feed.fetched_at
  end

  should 'expire feeds after a certain period' do
    # save current time
    now = Time.now

    # Noosfero is configured to update feeds every 4 hours
    FeedUpdater.stubs(:update_interval).returns(4.hours)

    expired = fast_create(:external_feed)
    not_expired = fast_create(:external_feed)

    # 5 hours ago
    Time.stubs(:now).returns(now  - 5.hours)
    expired.finish_fetch

    # 3 hours ago
    Time.stubs(:now).returns(now - 3.hours)
    not_expired.finish_fetch

    # now one feed should be expired and the not the other
    Time.stubs(:now).returns(now)
    expired_list = ExternalFeed.expired
    assert_includes expired_list, expired
    assert_not_includes expired_list, not_expired
  end

  should 'consider recently-created instance as expired' do
    new = fast_create(:external_feed)
    assert_includes ExternalFeed.expired, new
  end

  should 'have an update errors counter' do
    assert_equal 3, build(ExternalFeed, :update_errors => 3).update_errors
  end

  should 'have 0 update errors by default' do
    assert_equal 0, ExternalFeed.new.update_errors
  end

  should 'save hour when feed was fetched' do
    external_feed = create(:external_feed)

    now = Time.zone.parse('2009-01-23 09:35')
    Time.stubs(:now).returns(now)

    external_feed.finish_fetch
    external_feed.reload

    assert_equal 9, external_feed.fetched_at.hour
    assert_equal 35, external_feed.fetched_at.min
  end

  should 'strip content of style and class attributes' do
    blog = create_blog
    e = build(:external_feed, :blog => blog)
    e.add_item('Article title', 'http://orig.link.invalid', Time.now, '<p style="color: red">Html content 1.</p>')
    e.add_item('Article title 2', 'http://orig.link.invalid', Time.now, '<p class="myclass">Html content 2.</p>')
    e.add_item('Article title 3', 'http://orig.link.invalid', Time.now, '<img src="noosfero.png" />')

    dd = []
    Article.where(['parent_id = ?', blog.id]).all.each do |a|
      next if a.kind_of?(RssFeed)
      dd << a.body.to_s.strip.gsub(/\s+/, ' ')
    end
    assert_equal '<img src="noosfero.png"><p>Html content 1.</p><p>Html content 2.</p>', dd.sort.join
  end

  should 'use feed title as author name' do
    blog = create_blog
    e = build(:external_feed, :blog => blog, :feed_title => 'The Source')
    e.add_item('Article title', 'http://orig.link.invalid', Time.now, '<p style="color: red">Html content 1.</p>')

    assert_equal "The Source", blog.posts.first.author_name

  end

  should 'allow mass assign attributes' do
    p = create_user('testuser').person
    blog = fast_create(Blog, :profile_id => p.id, :name => 'Blog test')

    assert_difference 'ExternalFeed.count', 1 do
      efeed = blog.create_external_feed(:address => 'http://invalid.url', :enabled => true, :only_once => 'false')
    end
  end

end
