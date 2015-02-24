require_relative "../test_helper"

class CommentHelperTest < ActiveSupport::TestCase

  include CommentHelper
  include ActionView::Helpers::TagHelper
  include NoosferoTestHelper

  def setup
    @user = create_user('usertest').person
    @profile = @user
    self.stubs(:logged_in?).returns(true)
    self.stubs(:report_abuse).returns('<a href="#">link</a>')
    self.stubs(:expirable_comment_link).returns('<a href="#">link</a>')
    @plugins = mock
    @plugins.stubs(:dispatch).returns([])
  end

  attr_reader :user, :profile

  should 'show menu if it has links for actions' do
    article = Article.new(:profile => profile)
    comment = build(Comment, :article => article)
    menu = comment_actions(comment)
    assert_match /class=\"comment-actions\"/, menu
  end

  should 'do not show menu if it has no actions' do
    comment = Comment.new
    self.stubs(:links_for_comment_actions).returns([])
    menu = comment_actions(comment)
    assert_no_match /class=\"comment-actions\"/, menu
  end

  should 'do not show menu if it has nil actions only' do
    comment = Comment.new
    self.stubs(:link_for_report_abuse).returns(nil)
    self.stubs(:link_for_spam).returns(nil)
    self.stubs(:link_for_edit).returns(nil)
    self.stubs(:link_for_remove).returns(nil)
    menu = comment_actions(comment)
    assert_no_match /class=\"comment-actions\"/, menu
  end

  should 'include actions of plugins in menu' do
    article = Article.new(:profile => profile)
    comment = build(Comment, :article => article)
    plugin_action = {:link => 'plugin_action'}
    @plugins.stubs(:dispatch).returns([plugin_action])
    links = links_for_comment_actions(comment)
    assert_includes links, plugin_action
  end

  should 'include lambda actions of plugins in menu' do
    article = Article.new(:profile => profile)
    comment = build(Comment, :article => article)
    plugin_action = proc{[{:link => 'plugin_action'}, {:link => 'plugin_action2'}]}
    @plugins.stubs(:dispatch).returns([plugin_action])
    links = links_for_comment_actions(comment)
    assert_includes links, {:link => 'plugin_action'}
    assert_includes links, {:link => 'plugin_action2'}
  end

  should 'return link for report abuse action when comment has a author' do
    comment = Comment.new
    comment.author = user
    link = link_for_report_abuse(comment)
    assert link
  end

  should 'do not return link for report abuse action when comment has no author' do
    comment = Comment.new
    link = link_for_report_abuse(comment)
    assert !link
  end

  should 'return link for mark comment as spam' do
    comment = Comment.new
    comment.stubs(:can_be_marked_as_spam_by?).with(user).returns(true)
    link = link_for_spam(comment)
    assert_match /Mark as SPAM/, link[:link]
  end

  should 'not return link for mark comment as spam if user does not have the permissions' do
    comment = Comment.new
    comment.stubs(:can_be_marked_as_spam_by?).with(user).returns(false)
    link = link_for_spam(comment)
    assert_nil link
  end

  should 'return link for mark comment as not spam' do
    comment = Comment.new
    comment.spam = true
    comment.stubs(:can_be_marked_as_spam_by?).with(user).returns(true)
    link = link_for_spam(comment)
    assert_match /Mark as NOT SPAM/, link[:link]
  end

  should 'not return link for mark comment as not spam if user does not have the permissions' do
    comment = Comment.new
    comment.spam = true
    comment.stubs(:can_be_marked_as_spam_by?).with(user).returns(false)
    link = link_for_spam(comment)
    assert_nil link
  end

  should 'do not return link for edit comment' do
    comment = Comment.new
    comment.stubs(:can_be_updated_by?).with(user).returns(false)
    link = link_for_edit(comment)
    assert_nil link
  end

  should 'return link for edit comment' do
    comment = Comment.new
    comment.stubs(:can_be_updated_by?).with(user).returns(true)
    link = link_for_edit(comment)
    assert link
  end

  should 'do not return link for remove comment' do
    comment = Comment.new
    comment.stubs(:can_be_destroyed_by?).with(user).returns(false)
    link = link_for_remove(comment)
    assert_nil link
  end

  should 'return link for remove comment' do
    comment = Comment.new
    comment.stubs(:can_be_destroyed_by?).with(user).returns(true)
    link = link_for_remove(comment)
    assert link
  end

  should 'include actions of plugins in action bar' do
    comment = Comment.new
    plugin_action = {:link => 'plugin_action', :action_bar => true}
    @plugins.stubs(:dispatch).returns([plugin_action])
    html = comment_actions(comment)
    assert_match /plugin_action/, Nokogiri::HTML.fragment(html).css('.comments-action-bar').to_html
  end

  def link_to_function(content, url, options = {})
    link_to(content, url, options)
  end

end

