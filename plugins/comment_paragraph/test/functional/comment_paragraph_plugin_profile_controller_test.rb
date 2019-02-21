require_relative '../test_helper'
require_relative '../../controllers/profile/comment_paragraph_plugin_profile_controller'

# Re-raise errors caught by the controller.
class CommentParagraphPluginProfileController; def rescue_action(e) raise e end; end

class CommentParagraphPluginProfileControllerTest < ActionDispatch::IntegrationTest

  def setup
    @profile = create_user('testuser').person
    @article = profile.articles.build(:name => 'test')
    @article.save!
    @environment = Environment.default
    @environment.enabled_plugins = ['CommentParagraphPlugin']
    @environment.save!
  end
  attr_reader :article, :profile

  should 'be able to show paragraph comments' do
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :paragraph_uuid => 0)
    get comment_paragraph_plugin_profile_path(@profile.identifier, action: :view_comments), params:{ :article_id => article.id, :paragraph_uuid => 0}, xhr: true
    assert_select "#comment-#{comment.id}"
  end

  should 'do not show global comments' do
    global_comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'global comment', :body => 'global', :paragraph_uuid => nil)
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :paragraph_uuid => 0)
    get  comment_paragraph_plugin_profile_path(@profile.identifier, action: :view_comments), params: { :article_id => article.id, :paragraph_uuid => 0}, xhr: true
    assert_select "#comment-#{global_comment.id}", 0
    assert_select "#comment-#{comment.id}"
  end

  should 'be able to show all comments of a paragraph' do
    fast_create(Comment, :created_at => Time.now - 1.days, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'a comment', :paragraph_uuid => 0)
    fast_create(Comment, :created_at => Time.now - 2.days, :source_id => article, :author_id => profile, :title => 'b comment', :body => 'b comment', :paragraph_uuid => 0)
    fast_create(Comment, :created_at => Time.now - 3.days, :source_id => article, :author_id => profile, :title => 'c comment', :body => 'c comment', :paragraph_uuid => 0)
    fast_create(Comment, :created_at => Time.now - 4.days, :source_id => article, :author_id => profile, :title => 'd comment', :body => 'd comment', :paragraph_uuid => 0)
    get  comment_paragraph_plugin_profile_path(@profile.identifier, action: :view_comments), params:{ :article_id => article.id, :paragraph_uuid => 0}, xhr: true
    assert_match /a comment/, @response.body
    assert_match /b comment/, @response.body
    assert_match /c comment/, @response.body
    assert_match /d comment/, @response.body
  end

  should 'load the comment form for a paragraph' do
    login_as_rails5('testuser')
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala', :paragraph_uuid => 0)
    get  comment_paragraph_plugin_profile_path(@profile.identifier, action: :comment_form), params: { :article_id => article.id, :paragraph_uuid => 0}, xhr: true
    assert_tag tag: "textarea", attributes: { id: 'comment-field' }
    assert_tag tag: "input", attributes: { name: 'comment[paragraph_uuid]', value: '0', type: 'hidden' }
  end

  should 'export comments as CSV' do
    comment1 = fast_create(Comment, :created_at => Time.now - 1.days, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'a comment', :paragraph_uuid => nil)
    comment2 = fast_create(Comment, :created_at => Time.now - 2.days, :source_id => article, :author_id => profile, :title => 'b comment', :body => 'b comment', :paragraph_uuid => nil)
    get  comment_paragraph_plugin_profile_path(@profile.identifier, action: :export_comments), params: {:id => article.id}, xhr: true
    assert_equal 'text/csv; header=present', @response.content_type
    lines = @response.body.split("\n")
    assert_equal '"paragraph_id","paragraph_text","comment_id","comment_reply_to","comment_title","comment_content","comment_author_name","comment_author_email","comment_date"', lines.first
    assert_equal "\"\",\"\",\"#{comment2.id}\",\"\",\"b comment\",\"b comment\",\"#{comment2.author_name}\",\"#{comment2.author_email}\",\"#{comment2.created_at}\"", lines.second
  end

  should 'not export any comments as CSV' do
    get  comment_paragraph_plugin_profile_path(@profile.identifier, action: :export_comments), params: {:id => article.id}, xhr: true
    assert_equal "No comments for article[#{article.id}]: #{article.path}", @response.body.split("\n")[0]
  end
end
