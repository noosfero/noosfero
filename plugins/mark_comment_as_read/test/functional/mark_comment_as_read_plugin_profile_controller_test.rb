require 'test_helper'
require_relative '../../controllers/profile/mark_comment_as_read_plugin_profile_controller'

class MarkCommentAsReadPluginProfileControllerTest <  ActionDispatch::IntegrationTest
  def setup
    @controller = MarkCommentAsReadPluginProfileController.new

    @profile = create_user('profile').person
    @article = TextArticle.create!(:profile => @profile, :name => 'An article')
    @comment = Comment.new(:source => @article, :author => @profile, :body => 'test')
    @comment.save!
    login_as_rails5(@profile.identifier)
    environment = Environment.default
    environment.enable_plugin(MarkCommentAsReadPlugin)
  end

  attr_reader :profile, :comment

  should 'mark comment as read' do
    post mark_comment_as_read_plugin_profile_path(profile.identifier, {action: :mark_as_read, :id => comment.id}), xhr: true
    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'mark comment as not read' do
    comment.mark_as_read(user)
    post mark_comment_as_read_plugin_profile_path(profile.identifier, {action: :mark_as_not_read, :id => comment.id}), xhr: true
    assert_match /\{\"ok\":true\}/, @response.body
  end
end
