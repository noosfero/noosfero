require_relative '../test_helper'
include ActionView::Helpers::FormTagHelper

class CommentParagraphPluginTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
    @user = create_user('testuser').person
    context = mock()
    context.stubs(:user).returns(@user)
    @plugin = CommentParagraphPlugin.new(context)
  end

  attr_reader :environment, :plugin, :user

  should 'have a name' do
    assert_not_equal Noosfero::Plugin.plugin_name, CommentParagraphPlugin::plugin_name
  end

  should 'describe yourself' do
    assert_not_equal Noosfero::Plugin.plugin_description, CommentParagraphPlugin::plugin_description
  end

  should 'have a js file' do
    assert !plugin.js_files.blank?
  end

  should 'have stylesheet' do
    assert plugin.stylesheet?
  end

  should 'not add comment_paragraph_selected_area if comment_paragraph_selected_area is blank' do
    comment = Comment.new
    comment.comment_paragraph_selected_area = ""
    comment.paragraph_uuid = 2
    cpp = CommentParagraphPlugin.new
    prok = cpp.comment_form_extra_contents({:comment=>comment, :paragraph_uuid=>4})
    assert_nil /comment_paragraph_selected_area/.match(prok.call.inspect)
  end

  should 'display button to toggle comment paragraph for users which can edit the article' do
    profile = fast_create(Profile)
    article = fast_create(Article, :profile_id => profile.id)
    article.expects(:comment_paragraph_plugin_enabled?).returns(true)
    article.expects(:allow_edit?).with(user).returns(true)

    assert_not_equal [], plugin.article_extra_toolbar_buttons(article)
  end

  should 'not display button to toggle comment paragraph for users which can not edit the article' do
    profile = fast_create(Profile)
    article = fast_create(Article, :profile_id => profile.id)
    article.expects(:comment_paragraph_plugin_enabled?).returns(true)
    article.expects(:allow_edit?).with(user).returns(false)

    assert_equal [], plugin.article_extra_toolbar_buttons(article)
  end

  should 'not display button to toggle comment paragraph if plugin is not enabled' do
    profile = fast_create(Profile)
    article = fast_create(Article, :profile_id => profile.id)
    article.expects(:comment_paragraph_plugin_enabled?).returns(false)

    assert_equal [], plugin.article_extra_toolbar_buttons(article)
  end

  should 'display Activate Comments title if comment paragraph plugin is activated' do
    profile = fast_create(Profile)
    article = fast_create(Article, :profile_id => profile.id)
    article.expects(:comment_paragraph_plugin_enabled?).returns(true)
    article.expects(:allow_edit?).with(user).returns(true)
    article.expects(:comment_paragraph_plugin_activated?).returns(false)

    assert_equal 'Activate Comments', plugin.article_extra_toolbar_buttons(article)[:title]
  end

  should 'display Deactivate Comments title if comment paragraph plugin is deactivated' do
    profile = fast_create(Profile)
    article = fast_create(Article, :profile_id => profile.id)
    article.expects(:comment_paragraph_plugin_enabled?).returns(true)
    article.expects(:allow_edit?).with(user).returns(true)
    article.expects(:comment_paragraph_plugin_activated?).returns(true)

    assert_equal 'Deactivate Comments', plugin.article_extra_toolbar_buttons(article)[:title]
  end

end
