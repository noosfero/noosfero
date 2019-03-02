require_relative '../test_helper'

class CommentControllerTest < ActionDispatch::IntegrationTest

  def setup
    @environment = Environment.default
    @environment.enable_plugin(RequireAuthToCommentPlugin)
    @community = fast_create(Community)
    @person = create_user.person
    @article = fast_create(TextArticle, :profile_id => @community.id, :body => "some article")
  end

  attr_reader :community, :article, :person

  should 'not make comments if not logged in' do
    assert_no_difference 'Comment.count' do
      post comment_index_path(community.identifier), params: {:id => article.id, :comment => {:body => "Some comment..."}, :confirm => 'true'}, xhr: true
    end

  end

  should 'make comments if logged in' do
    login_as_rails5 person.user.login
    assert_difference 'Comment.count', 1 do
      post comment_index_path(community.identifier), params: {:id => article.id, :comment => {:body => "Some comment..."}, :confirm => 'true'}, xhr: true
    end
  end
end
