require "test_helper"

class ContextContentPluginProfileControllerTest < ActionDispatch::IntegrationTest
  class ContextContentPluginProfileController; def rescue_action(e) raise e end; end

  def setup
    @profile = fast_create(Community)
    box = create(Box, owner_type: "Profile", owner_id: @profile.id)
    @block = ContextContentPlugin::ContextContentBlock.new
    @block.box = box
    @block.types = ["TextArticle"]
    @block.limit = 1
    owner = create_user("block-owner").person
    @block.box = owner.boxes.last
    @block.save!
    @page = fast_create(Folder, profile_id: @profile.id)
  end

  should "render response error if contents is nil" do
    get context_content_plugin_profile_path(@profile.identifier, :view_content, @block.id), params: { article_id: @page.id, page: 1, profile: @profile.identifier }, xhr: true
    assert_response 500
  end

  should "render error if page do not exists" do
    article = fast_create(TextArticle, parent_id: @page.id, profile_id: @profile.id)
    get context_content_plugin_profile_path(@profile.identifier, :view_content, @block.id), params: { article_id: @page.id, page: 2, profile: @profile.identifier }, xhr: true
    assert_response 500
  end

  should "replace div with content for page passed as parameter" do
    article1 = fast_create(TextArticle, parent_id: @page.id, profile_id: @profile.id, name: "article1")
    article2 = fast_create(TextArticle, parent_id: @page.id, profile_id: @profile.id, name: "article2")
    get context_content_plugin_profile_path(@profile.identifier, :view_content, @block.id), params: { article_id: @page.id, page: 2, profile: @profile.identifier }, xhr: true
    assert_response :success
    assert_match /context_content_#{@block.id}/, @response.body
    assert_match /context_content_more_#{@block.id}/, @response.body
    assert_match /article2/, @response.body
  end

  should "do not render pagination buttons if it has only one page" do
    article1 = fast_create(TextArticle, parent_id: @page.id, profile_id: @profile.id, name: "article1")
    get context_content_plugin_profile_path(@profile.identifier, :view_content, @block.id), params: { article_id: @page.id, page: 2, profile: @profile.identifier }, xhr: true
    assert_no_match /context_content_more_#{@block.id}/, @response.body
  end
end
