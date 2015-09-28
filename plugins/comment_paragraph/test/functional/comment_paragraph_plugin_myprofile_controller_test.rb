require_relative '../test_helper'

class CommentParagraphPluginMyprofileControllerTest < ActionController::TestCase

  def setup
    @environment = Environment.default
    @environment.enable_plugin(CommentParagraphPlugin)
    @profile = fast_create(Profile)
    @user = create_user_with_permission('testuser', 'post_content', @profile)
    login_as(@user.identifier)
    @article = fast_create(TextArticle, :profile_id => profile.id, :author_id => @user.id)
  end

  attr_reader :article, :profile, :user, :environment

  should 'toggle comment paragraph activation' do
    assert !article.comment_paragraph_plugin_activate
    get :toggle_activation, :id => article.id, :profile => profile.identifier
    assert article.reload.comment_paragraph_plugin_activate
    assert_redirected_to article.view_url
  end

  should 'deny access to toggle activation for forbidden users' do
    login_as(create_user('anotheruser').login)
    get :toggle_activation, :id => article.id, :profile => profile.identifier
    assert_response :forbidden
  end

  should 'deny access to toggle activation if plugin is not enabled' do
    environment.disable_plugin(CommentParagraphPlugin)
    get :toggle_activation, :id => article.id, :profile => profile.identifier
    assert_response :forbidden
  end

end
