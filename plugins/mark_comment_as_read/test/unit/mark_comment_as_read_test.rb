require 'test_helper'

class MarkCommentAsReadPluginTest < ActiveSupport::TestCase

  include ActionView::Helpers::TagHelper
  include NoosferoTestHelper

  def setup
    @plugin = MarkCommentAsReadPlugin.new
    @person = create_user('user').person
    @article = TinyMceArticle.create!(:profile => @person, :name => 'An article')
    @comment = Comment.create!(:source => @article, :author => @person, :body => 'test')
    self.stubs(:user).returns(@person)
    self.stubs(:profile).returns(@person)
  end

  attr_reader :plugin, :comment

  should 'show link when person is logged in' do
    action = @plugin.comment_actions(@comment)
    link = self.instance_eval(&action)
    assert link
  end

  should 'do not show link when person is not logged in' do
    self.stubs(:user).returns(nil)
    action = @plugin.comment_actions(@comment)
    link = self.instance_eval(&action)
    refute link
  end

  should 'return actions when comment is not read' do
    action = @plugin.comment_actions(@comment)
    links = self.instance_eval(&action)
    assert_equal 2, links.size
  end

  should 'return actions when comment is read' do
    @comment.mark_as_read(@person)
    action = @plugin.comment_actions(@comment)
    links = self.instance_eval(&action)
    assert_equal 2, links.size
  end

  should 'do not return any id when user is not logged in' do
    self.stubs(:user).returns(nil)
    action = @plugin.check_comment_actions(@comment)
    id = self.instance_eval(&action)
    refute id
  end

  should 'return id of mark as not read link when comment is read' do
    @comment.mark_as_read(@person)
    action = @plugin.check_comment_actions(@comment)
    id = self.instance_eval(&action)
    assert_equal "#comment-action-mark-as-not-read-#{@comment.id}", id
  end

  should 'return id of mark as read link when comment is not read' do
    action = @plugin.check_comment_actions(@comment)
    id = self.instance_eval(&action)
    assert_equal "#comment-action-mark-as-read-#{@comment.id}", id
  end

  should 'return javascript to mark comment as read' do
    @comment.mark_as_read(@person)
    content = @plugin.article_extra_contents(@article)
    assert self.instance_eval(&content)
  end

  should 'do not return extra content if comment is not marked as read' do
    content = @plugin.article_extra_contents(@article)
    refute self.instance_eval(&content)
  end

  should 'do not return extra content if user is not logged in' do
    @comment.mark_as_read(@person)
    self.stubs(:user).returns(nil)
    content = @plugin.article_extra_contents(@article)
    refute self.instance_eval(&content)
  end

  def link_to_function(content, url, options = {})
    link_to(content, url, options)
  end

end
