require_relative "../test_helper"

class ForumHelperTest < ActiveSupport::TestCase

  include BlogHelper
  include ForumHelper
  include ContentViewerHelper
  include ActionView::Helpers::AssetTagHelper
  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  def setup
    @environment = Environment.default
    @profile = create_user('forum_helper_test').person
    @forum = fast_create(Forum, :profile_id => profile.id, :name => 'Forum test')
  end

  attr :profile
  attr :forum

  def _(s); s; end
  def h(s); s; end

  should 'return a label for new children' do
    assert_kind_of String, cms_label_for_new_children
  end

  should 'return a label for edit' do
    assert_kind_of String, cms_label_for_edit
  end

  should 'list posts with different classes' do
    forum.children << older_post = create(TextileArticle, :name => 'First post', :profile => profile, :parent => forum, :published => false, :author => profile)
    one_month_later = Time.now + 1.month
    Time.stubs(:now).returns(one_month_later)
    forum.children << newer_post = create(TextileArticle, :name => 'Second post', :profile => profile, :parent => forum, :published => true, :author => profile)
    assert_match /forum-post position-1 first odd-post.*forum-post position-2 last not-published even-post/, list_forum_posts(forum.posts)
  end

  should 'return post update if it has no comments' do
    author = create_user('forum test author').person
    some_post = create(TextileArticle, :name => 'First post', :profile => profile, :parent => forum, :published => true, :author => author)
    assert some_post.comments.empty?
    out = last_topic_update(some_post)
    assert_match time_ago_in_words(some_post.updated_at), out
    assert_match /forum test author/, out
  end

  should 'return last comment date if it has comments' do
    some_post = create(TextileArticle, :name => 'First post', :profile => profile, :parent => forum, :published => true)
    a1, a2 = create_user('a1').person, create_user('a2').person
    some_post.comments << build(Comment, :title => 'test', :body => 'test', :author => a1, :created_at => Time.now - 1.day)
    some_post.comments << build(Comment, :title => 'test', :body => 'test', :author => a2, :created_at => Time.now)
    c = Comment.last
    assert_equal 2, some_post.comments.count
    out = last_topic_update(some_post)
    result = time_ago_in_words(c.created_at)
    assert_match result, out
    assert_match 'a2', out

    assert_match(/#{result} by <a href='[^']+'>a2<\/a>/, last_topic_update(some_post))
  end

  should "return last comment author's name from unauthenticated user" do
    some_post = create(TextileArticle, :name => 'First post', :profile => profile, :parent => forum, :published => true)
    some_post.comments << build(Comment, :name => 'John', :email => 'lenon@example.com', :title => 'test', :body => 'test')
    c = Comment.last
    out = last_topic_update(some_post)
    result = time_ago_in_words(c.created_at)
    assert_match "#{result} by John", out
    assert_match 'John', out

    assert_match(/#{result} by John/m, last_topic_update(some_post))
  end

  protected

  include NoosferoTestHelper

end
