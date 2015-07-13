require_relative '../test_helper'

class ContentViewerControllerTest < ActionController::TestCase

  def setup
    @profile = fast_create(Community)
    @page = fast_create(Article, :profile_id => @profile.id, :body => "<div class=\"macro\" data-macro-group_id=\"1\" data-macro='comment_group_plugin/allow_comment' ></div>")
    @environment = Environment.default
    @environment.enable_plugin(CommentGroupPlugin)
  end

  attr_reader :page

  should 'parse article body and render comment group view' do
    comment1 = fast_create(Comment, :group_id => 1, :source_id => page.id)
    get :view_page, @page.url
    assert_tag 'div', :attributes => {:class => 'comment_group_1'}
    assert_tag 'div', :attributes => {:id => 'comments_group_count_1'}
  end

end
