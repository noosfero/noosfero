require 'test_helper'
require_relative '../../controllers/mark_comment_as_read_plugin_profile_controller'

class MarkCommentAsReadPluginProfileControllerTest < ActionController::TestCase
  def setup
    @controller = MarkCommentAsReadPluginProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @profile = create_user('profile').person
    @article = TinyMceArticle.create!(:profile => @profile, :name => 'An article')
    @comment = Comment.new(:source => @article, :author => @profile, :body => 'test')
    @comment.save!
    login_as(@profile.identifier)
    environment = Environment.default
    environment.enable_plugin(MarkCommentAsReadPlugin)
    self.stubs(:user).returns(@profile)
  end

  attr_reader :profile, :comment

  should 'mark comment as read' do
    xhr :post, :mark_as_read, :profile => profile.identifier, :id => comment.id
    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'mark comment as not read' do
    xhr :post, :mark_as_not_read, :profile => profile.identifier, :id => comment.id
    assert_match /\{\"ok\":true\}/, @response.body
  end
end
