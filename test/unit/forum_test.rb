require_relative "../test_helper"

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
    b = create(Forum, :profile_id => p.id, :name => 'forum_feed_test', :body => 'Forum')
    assert_kind_of RssFeed, b.feed
  end

  should 'save feed options' do
    p = create_user('testuser').person
    p.articles << forum = build(Forum, :profile => p, :name => 'forum_feed_test', :body => 'Forum test')
    p.forum.feed = { :limit => 7 }
    assert_equal 7, Forum.find(forum.id).feed.limit
  end

  should 'save feed options after create forum' do
    p = create_user('testuser').person
    p.articles << forum = build(Forum, :profile => p, :name => 'forum_feed_test', :body => 'Forum test', :feed => { :limit => 7 })
    assert_equal 7, Forum.find(forum.id).feed.limit
  end

  should 'list 5 posts per page by default' do
    forum = Forum.new
    assert_equal 5, forum.posts_per_page
  end

  should 'update posts per page setting' do
    p = create_user('testuser').person
    p.articles << forum = build(Forum, :profile => p, :name => 'Forum test', :body => 'Forum test')
    forum.posts_per_page = 7
    assert forum.save!
    assert_equal 7, Forum.find(forum.id).posts_per_page
  end

  should 'has posts' do
    p = create_user('testuser').person
    p.articles << forum = build(Forum, :profile => p, :name => 'Forum test', :body => 'Forum test')
    post = fast_create(TextileArticle, :name => 'First post', :profile_id => p.id, :parent_id => forum.id)
    forum.children << post
    assert_includes forum.posts, post
  end

  should 'not includes rss feed in posts' do
    p = create_user('testuser').person
    forum = create(Forum, :profile_id => p.id, :name => 'Forum test', :body => 'Forum')
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
      create(Forum, :name => 'Another Forum', :profile => p, :body => 'Forum test')
    end
  end

  should 'not update slug from name for existing forum' do
    p = create_user('testuser').person
    forum = create(Forum, :name => 'Forum test', :profile_id => p.id, :body => 'Forum')
    new_name = 'Changed name'
    assert_not_equal new_name.to_slug, forum.slug
    forum.name = new_name
    assert_not_equal new_name.to_slug, forum.slug
  end

  should 'have posts' do
    assert Forum.new.has_posts?
  end

  should 'not accept uploads' do
    folder = fast_create(Forum)
    assert !folder.accept_uploads?
  end

  should 'be notifiable' do
    assert Forum.new.notifiable?
  end

  should 'get first paragraph' do
    f = fast_create(Forum, :body => '<p>First</p><p>Second</p>')
    assert_equal '<p>First</p>', f.first_paragraph
  end

  should 'not get first paragraph' do
    f = fast_create(Forum, :body => 'Nothing to do here')
    assert_equal '', f.first_paragraph
  end

  should 'provide first_paragraph even if body was not given' do
    f = fast_create(Forum)
    assert_equal '', f.first_paragraph
  end

  should 'provide first_paragraph even if body is nil' do
    f = fast_create(Forum, :body => nil)
    assert_equal '', f.first_paragraph
  end

  should 'include user that changes a forum as agreed with terms' do
    author = fast_create(Person)
    editor = fast_create(Person)
    forum = create(Forum, :profile => author, :name => 'Forum test', :body => 'Forum test', :has_terms_of_use => true, :last_changed_by => author)
    forum.last_changed_by = editor
    forum.save

    assert_equivalent [author, editor], forum.users_with_agreement
  end

  should 'not crash if forum has terms and last_changed does not exist' do
    profile = fast_create(Person)
    forum = Forum.create(:profile => profile, :name => 'Forum test', :body => 'Forum test', :has_terms_of_use => true)

    assert_equal [], forum.users_with_agreement
  end

  should 'agree with terms if forum doesn\'t have terms' do
    person = fast_create(Person)
    forum = fast_create(Forum)

    assert_equal true, forum.agrees_with_terms?(person)
  end

  should 'not agree with terms if user is logged in but did not accept it' do
    person = fast_create(Person)
    forum = Forum.create(:profile => person, :name => 'Forum test', :body => 'Forum test', :has_terms_of_use => true)

    assert_equal false, forum.agrees_with_terms?(person)
  end

  should 'agree with terms if user is logged in and accept it' do
    person = fast_create(Person)
    forum = Forum.create(:profile => person, :name => 'Forum test', :body => 'Forum test', :has_terms_of_use => true)
    forum.users_with_agreement << person
    forum.save

    assert_equal true, Forum.find(forum.id).agrees_with_terms?(person)
  end

end
