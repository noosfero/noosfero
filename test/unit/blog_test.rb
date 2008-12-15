require File.dirname(__FILE__) + '/../test_helper'

class BlogTest < ActiveSupport::TestCase

  should 'be an article' do
    assert_kind_of Article, Blog.new
  end

  should 'provide proper description' do
    assert_kind_of String, Blog.description
  end

  should 'provide proper short description' do
    assert_kind_of String, Blog.short_description
  end

  should 'provide own icon name' do
    assert_not_equal Article.new.icon_name, Blog.new.icon_name
  end

  should 'identify as folder' do
    assert Blog.new.folder?, 'blog must identity itself as folder'
  end

  should 'identify as blog' do
    assert Blog.new.blog?, 'blog must identity itself as blog'
  end

  should 'create rss feed automatically' do
    p = create_user('testuser').person
    b = Blog.create!(:profile => p, :name => 'blog_feed_test')
    assert_kind_of RssFeed, b.feed
  end

  should 'include articles body in feed by default' do
    p = create_user('testuser').person
    b = Blog.create!(:profile => p, :name => 'blog_feed_test')
    assert_equal 'body', b.feed.feed_item_description
  end

  should 'get first blog from profile' do
    p = create_user('testuser').person
    b = Blog.create!(:profile => p, :name => 'blog_feed_test')
    assert_equal p.blog, b
  end

  should 'save feed options' do
    p = create_user('testuser').person
    b = Blog.create!(:profile => p, :name => 'blog_feed_test')
    p.blog.feed = { :limit => 7 }
    assert_equal 7, p.blog.feed.limit
  end

  should 'includes only articles child of the same article on feed' do
    p = create_user('testuser').person
    b = Blog.create!(:profile => p, :name => 'blog_feed_test')
    assert_equal 'parent_and_children', b.feed.include
  end

  should 'save feed options after create blog' do
    p = create_user('testuser').person
    b = Blog.create!(:profile => p, :name => 'blog_feed_test', :feed => { :limit => 7 })

    p.blog.feed.reload
    assert_equal 7, p.blog.feed.limit
  end

  should 'list 20 posts per page by default' do
    blog = Blog.new
    assert_equal 20, blog.posts_per_page
  end

  should 'update posts per page setting' do
    p = create_user('testusermerda').person
    blog = Blog.create!(:profile => p, :name => 'Blog test')
    blog.reload
    blog.posts_per_page = 5
    assert blog.save!
    assert_equal 5, blog.posts_per_page
  end

  should 'has posts' do
    p = create_user('testusermerda').person
    blog = Blog.create!(:profile => p, :name => 'Blog test')
    post = TextileArticle.create!(:name => 'First post', :profile => p, :parent => blog)
    blog.children << post
    assert_includes blog.posts, post
  end

  should 'not includes rss feed in posts' do
    p = create_user('testusermerda').person
    blog = Blog.create!(:profile => p, :name => 'Blog test')
    assert_includes blog.children, blog.feed
    assert_not_includes blog.posts, blog.feed
  end

  should 'list posts ordered by created at' do
    p = create_user('testusermerda').person
    blog = Blog.create!(:profile => p, :name => 'Blog test', :profile => p)
    newer = TextileArticle.create!(:name => 'Post 2', :parent => blog, :profile => p)
    older = TextileArticle.create!(:name => 'Post 1', :parent => blog, :profile => p, :created_at => Time.now - 1.month)
    assert_equal [newer, older], blog.posts
  end

  should 'has filter' do
    p = create_user('testusermerda').person
    blog = Blog.create!(:profile => p, :name => 'Blog test', :profile => p)
    blog.filter = {:param => 'value'}
    assert_equal 'value', blog.filter[:param]
  end

end
