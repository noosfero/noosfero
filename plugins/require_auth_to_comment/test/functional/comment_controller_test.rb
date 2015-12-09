require_relative '../test_helper'

class CommentControllerTest < ActionController::TestCase

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
      xhr :post, :create, :profile => community.identifier, :id => article.id, :comment => {:body => "Some comment..."}, :confirm => 'true'
    end

  end

  should 'make comments if logged in' do
    login_as person.user.login
    assert_difference 'Comment.count', 1 do
      xhr :post, :create, :profile => community.identifier, :id => article.id, :comment => {:body => "Some comment..."}, :confirm => 'true'
    end
  end
end
