require_relative '../test_helper'
require_relative '../../controllers/public/comment_paragraph_plugin_public_controller'


# Re-raise errors caught by the controller.
class CommentParagraphPluginPublicController; def rescue_action(e) raise e end; end

class CommentParagraphPluginPublicControllerTest < ActionController::TestCase

  def setup
    @profile = create_user('testuser').person
    @article = profile.articles.create!(:name => 'test')
  end
  attr_reader :article, :profile

  should 'be able to return paragraph_uuid for a comment' do
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :paragraph_uuid => 0)
    cid = comment.id
    xhr :get, :comment_paragraph, :id => cid
    assert_equal({'paragraph_uuid' => '0'}, ActiveSupport::JSON.decode(@response.body))
  end

  should 'return paragraph_uuid=null for a global comment' do
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala' )
    xhr :get, :comment_paragraph, :id => comment.id
    assert_equal({'paragraph_uuid' => nil}, ActiveSupport::JSON.decode(@response.body))
  end

end
