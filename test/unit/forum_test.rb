require File.dirname(__FILE__) + '/../test_helper'

class ForumTest < ActiveSupport::TestCase

  should 'be an article' do
    assert_kind_of Article, Forum.new
  end

  should 'provide proper description' do
    assert_kind_of String, Forum.description
  end

  should 'provide own icon name' do
    assert_not_equal Article.icon_name, Forum.icon_name
  end

  should 'provide forum as icon name' do
    assert_equal 'forum', Forum.icon_name
  end

  should 'identify as folder' do
    assert Forum.new.folder?, 'forum must identity itself as folder'
  end

  should 'identify as forum' do
    assert Forum.new.forum?, 'forum must identity itself as forum'
  end

  should 'create rss feed automatically' do
    p = create_user('testuser').person
    b = create(Forum, :profile_id => p.id, :name => 'forum_feed_test')
    assert_kind_of RssFeed, b.feed
  end

  should 'save feed options' do
    p = create_user('testuser').person
    p.articles << Forum.new(:profile => p, :name => 'forum_feed_test')
    p.forum.feed = { :limit => 7 }
    assert_equal 7, p.forum.feed.limit
  end

  should 'save feed options after create forum' do
    p = create_user('testuser').person
    p.articles << Forum.new(:profile => p, :name => 'forum_feed_test', :feed => { :limit => 7 })
    assert_equal 7, p.forum.feed.limit
  end

  should 'list 5 posts per page by default' do
    forum = Forum.new
    assert_equal 5, forum.posts_per_page
  end

  should 'update posts per page setting' do
    p = create_user('testuser').person
    p.articles << Forum.new(:profile => p, :name => 'Forum test')
    forum = p.forum
    forum.posts_per_page = 7
    assert forum.save!
    assert_equal 7, p.forum.posts_per_page
  end

  should 'has posts' do
    p = create_user('testuser').person
    forum = fast_create(Forum, :profile_id => p.id, :name => 'Forum test')
    post = fast_create(TextileArticle, :name => 'First post', :profile_id => p.id, :parent_id => forum.id)
    forum.children << post
    assert_includes forum.posts, post
  end

  should 'not includes rss feed in posts' do
    p = create_user('testuser').person
    forum = create(Forum, :profile_id => p.id, :name => 'Forum test')
    assert_includes forum.children, forum.feed
    assert_not_includes forum.posts, forum.feed
  end

  should 'list posts ordered by updated at' do
    p = create_user('testuser').person
    forum = fast_create(Forum, :profile_id => p.id, :name => 'Forum test')
    newer = create(TextileArticle, :name => 'Post 2', :parent => forum, :profile => p)
    older = create(TextileArticle, :name => 'Post 1', :parent => forum, :profile => p)
    older.updated_at = Time.now - 1.month
    older.stubs(:record_timestamps).returns(false)
    older.save!
    assert_equal [newer, older], forum.posts
  end

  should 'profile has more then one forum' do
    p = create_user('testuser').person
    fast_create(Forum, :name => 'Forum test', :profile_id => p.id)
    assert_nothing_raised ActiveRecord::RecordInvalid do
      Forum.create!(:name => 'Another Forum', :profile => p)
    end
  end

  should 'not update slug from name for existing forum' do
    p = create_user('testuser').person
    forum = Forum.create!(:name => 'Forum test', :profile => p)
    assert_equal 'forum-test', forum.slug
    forum.name = 'Changed name'
    assert_not_equal 'changed-name', forum.slug
  end

  should 'have posts' do
    assert Forum.new.has_posts?
  end

  should 'not accept uploads' do
    folder = fast_create(Forum)
    assert !folder.accept_uploads?
  end

end
