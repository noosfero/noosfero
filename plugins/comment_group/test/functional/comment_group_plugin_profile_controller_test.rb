require_relative '../test_helper'
require_relative '../../controllers/profile/comment_group_plugin_profile_controller'

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
    assert_template 'comment_group_plugin_profile/view_comments'
    assert_select_rjs '#comments_list_group_0'
    assert_select_rjs :replace_html, '#comment-count-0'
    assert_equal 1, assigns(:comments_count)
  end

  should 'do not show global comments' do
    fast_create(Comment, :source_id => article, :author_id => profile, :title => 'global comment', :body => 'global', :group_id => nil)
    fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :group_id => 0)
    xhr :get, :view_comments, :profile => @profile.identifier, :article_id => article.id, :group_id => 0
    assert_template 'comment_group_plugin_profile/view_comments'
    assert_select_rjs '#comments_list_group_0'
    assert_select_rjs :replace_html, '#comment-count-0'
    assert_equal 1, assigns(:comments_count)
  end

  should 'show first page comments only' do
    comment1 = fast_create(Comment, :created_at => Time.now - 1.days, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'secondpage', :group_id => 0)
    comment2 = fast_create(Comment, :created_at => Time.now - 2.days, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'firstpage 1', :group_id => 0)
    comment3 = fast_create(Comment, :created_at => Time.now - 3.days, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'firstpage 2', :group_id => 0)
    comment4 = fast_create(Comment, :created_at => Time.now - 4.days, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'firstpage 3', :group_id => 0)
    xhr :get, :view_comments, :profile => @profile.identifier, :article_id => article.id, :group_id => 0
    assert_match /firstpage 1/, @response.body
    assert_match /firstpage 2/, @response.body
    assert_match /firstpage 3/, @response.body
    assert_no_match /secondpage/, @response.body
  end

  should 'show link to display more comments' do
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :group_id => 0)
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :group_id => 0)
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :group_id => 0)
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'secondpage', :body => 'secondpage', :group_id => 0)
    xhr :get, :view_comments, :profile => @profile.identifier, :article_id => article.id, :group_id => 0
    assert_match /group_comment_page=2/, @response.body
  end

  should 'do not show link to display more comments if do not have more pages' do
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :group_id => 0)
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :group_id => 0)
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :group_id => 0)
    xhr :get, :view_comments, :profile => @profile.identifier, :article_id => article.id, :group_id => 0
    assert_no_match /group_comment_page/, @response.body
  end

  should 'do not show link to display more comments if do not have any comments' do
    xhr :get, :view_comments, :profile => @profile.identifier, :article_id => article.id, :group_id => 0
    assert_no_match /group_comment_page/, @response.body
  end

end
