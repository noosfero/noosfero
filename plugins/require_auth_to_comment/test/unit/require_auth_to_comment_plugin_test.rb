require File.dirname(__FILE__) + '/../../../../test/test_helper'

class RequireAuthToCommentPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = RequireAuthToCommentPlugin.new
    @comment = Comment.new
  end

  attr_reader :plugin, :comment

  should 'reject comments for unauthenticated users' do
    plugin.context = logged_in(false)
    plugin.filter_comment(comment)
    assert comment.rejected?
  end

  should 'allow comments from authenticated users' do
    plugin.context = logged_in(true)
    plugin.filter_comment(comment)
    assert !comment.rejected?
  end

  should 'allow comments from unauthenticated users if allowed by profile' do
    plugin.context = logged_in(false)
    plugin.context.profile.allow_unauthenticated_comments = true

    plugin.filter_comment(comment)
    assert !comment.rejected?
  end

  protected

  def logged_in(boolean)
    controller = mock()
    controller.stubs(:logged_in?).returns(boolean)
    controller.stubs(:profile).returns(Profile.new)
    controller
  end

end
