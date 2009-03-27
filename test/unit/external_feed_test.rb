require File.dirname(__FILE__) + '/../test_helper'

class ExternalFeedTest < ActiveSupport::TestCase

  def setup
    @profile = create_user('test-person').person
    @blog = Blog.create!(:name => 'test-blog', :profile => @profile)
  end
  attr_reader :profile, :blog

  should 'require blog' do
    e = ExternalFeed.new(:address => 'http://localhost')
    assert !e.valid?
    e.blog = blog
    assert e.save!
  end

  should 'belongs to blog' do
    e = ExternalFeed.create!(:address => 'http://localhost', :blog => blog)
    e.reload
    assert_equal blog, e.blog
  end

  should 'not add same item twice' do
    e = ExternalFeed.create!(:address => 'http://localhost', :blog => blog)
    assert e.add_item('Article title', 'http://orig.link.invalid', Time.now, 'Content for external post')
    assert !e.add_item('Article title', 'http://orig.link.invalid', Time.now, 'Content for external post')
    assert_equal 1, e.blog.posts.size
  end

  should 'nothing when clear' do
    assert_respond_to ExternalFeed.new, :clear
  end

  should 'not limit' do
    assert_equal 0, ExternalFeed.new.limit
  end

  should 'disable external feed if fetch only once on finish fetch' do
    e = ExternalFeed.create(:address => 'http://localhost', :blog => blog, :only_once => true, :enabled => true)
    assert e.enabled
    assert e.finish_fetch
    assert !e.enabled
  end

  should 'add items to blog as posts' do
    handler = FeedHandler.new
    e = ExternalFeed.create!(:address => 'test/fixtures/files/feed.xml', :blog => blog, :enabled => true)
    handler.process(e)
    assert_equal ["Last POST", "Second POST", "First POST"], e.blog.posts.map{|i| i.title}
  end

  should 'require address if enabled' do
    e = ExternalFeed.new(:blog => blog, :enabled => true)
    assert !e.valid?
  end

  should 'not require address if disabled' do
    e = ExternalFeed.new(:blog => blog, :enabled => false)
    assert e.valid?
  end

end
