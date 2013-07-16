require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/profile/comment_group_plugin_profile_controller'

# Re-raise errors caught by the controller.
class CommentGroupPluginProfileController; def rescue_action(e) raise e end; end

class CommentGroupPluginProfileControllerTest < ActionController::TestCase

  def setup
    @controller = CommentGroupPluginProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testuser').person
    @article = profile.articles.build(:name => 'test')
    @article.save!
  end
  attr_reader :article
  attr_reader :profile

  should 'be able to show group comments' do
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :group_id => 0)
    xhr :get, :view_comments, :profile => @profile.identifier, :article_id => article.id, :group_id => 0
    assert_template 'comment/_comment.rhtml'
    assert_match /comments_list_group_0/, @response.body
    assert_match /\"comment-count-0\", \"1\"/, @response.body
  end

  should 'do not show global comments' do
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'global comment', :body => 'global', :group_id => nil)
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :group_id => 0)
    xhr :get, :view_comments, :profile => @profile.identifier, :article_id => article.id, :group_id => 0
    assert_template 'comment/_comment.rhtml'
    assert_match /comments_list_group_0/, @response.body
    assert_match /\"comment-count-0\", \"1\"/, @response.body
  end

end
