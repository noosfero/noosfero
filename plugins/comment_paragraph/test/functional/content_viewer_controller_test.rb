require_relative '../test_helper'

class ContentViewerController
  append_view_path File.join(File.dirname(__FILE__) + '/../../views')
  def rescue_action(e)
    raise e
  end
end

class ContentViewerControllerTest < ActionController::TestCase

  def setup
    @environment = Environment.default
    @environment.enable_plugin(CommentParagraphPlugin)
    @profile = fast_create(Community)
    @page = fast_create(TextArticle, :profile_id => @profile.id, :body => "<p>inner text</p>")
    @page.comment_paragraph_plugin_activate = true
    @page.save!
  end

  attr_reader :page

  should 'parse article body and render comment paragraph view' do
    comment1 = fast_create(Comment, :paragraph_uuid => 0, :source_id => page.id)
    get :view_page, @page.url
    assert_tag 'div', :attributes => {:class => 'comment_paragraph'}
  end

end
