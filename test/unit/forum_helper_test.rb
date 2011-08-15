require File.dirname(__FILE__) + '/../test_helper'

class ForumHelperTest < Test::Unit::TestCase

  include BlogHelper
  include ForumHelper
  include ContentViewerHelper
  include ActionView::Helpers::AssetTagHelper
  include ApplicationHelper

  def setup
    @environment = Environment.default
    @profile = create_user('forum_helper_test').person
    @forum = fast_create(Forum, :profile_id => profile.id, :name => 'Forum test')
    Comment.skip_captcha!
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
    forum.children << newer_post = TextileArticle.create!(:name => 'Second post', :profile => profile, :parent => forum, :published => true)
    older_post.updated_at = Time.now.ago(1.month); older_post.send(:update_without_callbacks)
    assert_match /forum-post position-1 first odd-post.*forum-post position-2 last not-published even-post/, list_forum_posts(forum.posts)
  end

  should 'return post update if it has no comments' do
    author = create_user('forum test author').person
    some_post = TextileArticle.create!(:name => 'First post', :profile => profile, :parent => forum, :published => true)
    some_post.expects(:author).returns(author).times(2)
    assert some_post.comments.empty?
    assert_match /#{some_post.updated_at.to_s} ago by <a href='[^']+'>forum test author<\/a>/, last_topic_update(some_post)
  end

  should 'return last comment date if it has comments' do
    some_post = TextileArticle.create!(:name => 'First post', :profile => profile, :parent => forum, :published => true)
    a1, a2 = create_user('a1').person, create_user('a2').person
    some_post.comments << Comment.new(:title => 'test', :body => 'test', :author => a1)
    some_post.comments << Comment.new(:title => 'test', :body => 'test', :author => a2)
    c = Comment.last
    assert_equal 2, some_post.comments.count
    assert_match /#{c.created_at.to_s} ago by <a href='[^']+'>a2<\/a>/, last_topic_update(some_post)
  end

  should "return last comment author's name from unauthenticated user" do
    some_post = TextileArticle.create!(:name => 'First post', :profile => profile, :parent => forum, :published => true)
    some_post.comments << Comment.new(:name => 'John', :email => 'lenon@example.com', :title => 'test', :body => 'test')
    c = Comment.last
    assert_match /#{c.created_at.to_s} ago by John/m, last_topic_update(some_post)
  end

  protected

  include NoosferoTestHelper

  def time_ago_as_sentence(t = Time.now)
    t.to_s
  end

end
