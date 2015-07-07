require File.dirname(__FILE__) + '/../../../../test/test_helper'

class RequireAuthToCommentPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = RequireAuthToCommentPlugin.new
    @comment = Comment.new
    @environment = fast_create(Environment)
  end

  attr_reader :plugin, :comment, :environment

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

  should 'the default require type setting be hide_button' do
    assert_equal 'hide_button', plugin.class.require_type_default_setting
  end

  should 'display_login_popup? be false by default' do
    context = mock();
    context.expects(:environment).returns(environment)
    plugin.expects(:context).returns(context)
    assert !plugin.display_login_popup?
  end

  should 'display_login_popup? be true if require_type is defined as display_login_popup' do
    context = mock();
    context.expects(:environment).returns(environment)
    environment[:settings] = {:require_auth_to_comment_plugin => {:require_type => "display_login_popup"}}
    plugin.expects(:context).returns(context)
    assert plugin.display_login_popup?
  end

  should 'not display stylesheet if login popup is active' do
    plugin.expects(:display_login_popup?).returns(true)
    assert !plugin.stylesheet?
  end

  should 'display stylesheet if login popup is inactive' do
    plugin.expects(:display_login_popup?).returns(false)
    assert plugin.stylesheet?
  end

  protected

  def logged_in(boolean)
    controller = mock()
    controller.stubs(:logged_in?).returns(boolean)
    controller.stubs(:profile).returns(Profile.new)
    controller
  end

end
