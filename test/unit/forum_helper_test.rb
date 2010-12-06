require File.dirname(__FILE__) + '/../test_helper'

class ForumHelperTest < Test::Unit::TestCase

  include BlogHelper
  include ForumHelper
  include ContentViewerHelper
  include ActionView::Helpers::AssetTagHelper
  include ApplicationHelper

  def setup
    stubs(:show_date).returns('')
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
    forum.children << newer_post = TextileArticle.create!(:name => 'Second post', :profile => profile, :parent => forum, :published => true)
    older_post.updated_at = Time.now.ago(1.month); older_post.send(:update_without_callbacks)
    assert_match /forum-post position-1 first odd-post.*forum-post position-2 last not-published even-post/, list_forum_posts(forum.posts)
  end

  should 'return post update if it has no comments' do
    author = create_user('forum test author').person
    some_post = TextileArticle.create!(:name => 'First post', :profile => profile, :parent => forum, :published => true)
    some_post.expects(:author).returns(author)
    assert some_post.comments.empty?
    assert_equal "#{some_post.updated_at.to_s} ago by #{author.name}", last_topic_update(some_post)
  end

  should 'return last comment date if it has comments' do
    some_post = TextileArticle.create!(:name => 'First post', :profile => profile, :parent => forum, :published => true)
    a1, a2 = create_user('a1').person, create_user('a2').person
    some_post.comments << Comment.new(:title => 'test', :body => 'test', :author => a1)
    some_post.comments << Comment.new(:title => 'test', :body => 'test', :author => a2)
    c = Comment.last
    assert_equal 2, some_post.comments.count
    assert_equal "#{c.created_at.to_s} ago by #{a2.name}", last_topic_update(some_post)
  end

  protected

  def will_paginate(arg1, arg2)
  end

  def link_to(content, url)
    content
  end

  def tag(tag, args = {})
    attrs = args.map{|k,v| "#{k}='#{v}'"}.join(' ')
    "<#{tag} #{attrs} />"
  end

  def content_tag(tag, content, options = {})
    tag_attr = options.blank? ? "" : options.collect{ |o| "#{o[0]}=\"#{o[1]}\"" }.join(' ')
    "<#{tag}#{tag_attr}>#{content}</#{tag}>"
  end

  def time_ago_as_sentence(t = Time.now)
    t.to_s
  end

end
