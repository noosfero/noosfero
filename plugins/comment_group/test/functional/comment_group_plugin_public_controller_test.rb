require_relative '../test_helper'
require_relative '../../controllers/public/comment_group_plugin_public_controller'

class CommentGroupPluginPublicControllerTest < ActionController::TestCase

  def setup
    @controller = CommentGroupPluginPublicController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testuser').person
    @article = profile.articles.build(:name => 'test')
    @article.save!
  end
  attr_reader :article
  attr_reader :profile

  should 'be able to return group_id for a comment' do
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :group_id => 0)
    xhr :get, :comment_group, :id => comment.id
    assert_match /\{\"group_id\":0\}/, @response.body
  end

  should 'return group_id=null for a global comment' do
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala' )
    xhr :get, :comment_group, :id => comment.id
    assert_match /\{\"group_id\":null\}/, @response.body
  end

end
