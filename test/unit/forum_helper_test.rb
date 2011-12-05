require File.dirname(__FILE__) + '/../test_helper'

class ForumHelperTest < ActiveSupport::TestCase

  include BlogHelper
  include ForumHelper
  include ContentViewerHelper
  include ActionView::Helpers::AssetTagHelper
  include ApplicationHelper

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
    forum.children << older_post = TextileArticle.create!(:name => 'First post', :profile => profile, :parent => forum, :published => false)
    one_month_later = Time.now + 1.month
    Time.stubs(:now).returns(one_month_later)
    forum.children << newer_post = TextileArticle.create!(:name => 'Second post', :profile => profile, :parent => forum, :published => true)
    assert_match /forum-post position-1 first odd-post.*forum-post position-2 last not-published even-post/, list_forum_posts(forum.posts)
  end

  should 'return post update if it has no comments' do
    author = create_user('forum test author').person
    some_post = TextileArticle.create!(:name => 'First post', :profile => profile, :parent => forum, :published => true)
    some_post.expects(:author).returns(author).times(2)
    assert some_post.comments.empty?
    out = last_topic_update(some_post)
    assert_match some_post.updated_at.to_s, out
    assert_match /forum test author/, out
  end

  should 'return last comment date if it has comments' do
    some_post = TextileArticle.create!(:name => 'First post', :profile => profile, :parent => forum, :published => true)
    a1, a2 = create_user('a1').person, create_user('a2').person
    some_post.comments << Comment.new(:title => 'test', :body => 'test', :author => a1)
    some_post.comments << Comment.new(:title => 'test', :body => 'test', :author => a2)
    c = Comment.last
    assert_equal 2, some_post.comments.count
    out = last_topic_update(some_post)
    assert_match c.created_at.to_s, out
    assert_match 'a2', out
  end

  should "return last comment author's name from unauthenticated user" do
    some_post = TextileArticle.create!(:name => 'First post', :profile => profile, :parent => forum, :published => true)
    some_post.comments << Comment.new(:name => 'John', :email => 'lenon@example.com', :title => 'test', :body => 'test')
    c = Comment.last
    out = last_topic_update(some_post)
    assert_match "#{c.created_at.to_s} ago by John", out
    assert_match 'John', out
  end

  protected

  include NoosferoTestHelper

  def time_ago_as_sentence(t = Time.now)
    t.to_s
  end

end
