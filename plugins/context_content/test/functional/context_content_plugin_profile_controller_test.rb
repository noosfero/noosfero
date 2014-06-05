require 'test_helper'

class ContextContentPluginProfileControllerTest < ActionController::TestCase

  class ContextContentPluginProfileController; def rescue_action(e) raise e end; end

  def setup
    @profile = fast_create(Community)
    box = create(Box, :owner_type => 'Profile', :owner_id => @profile.id)
    @block = ContextContentPlugin::ContextContentBlock.new
    @block.box = box
    @block.types = ['TinyMceArticle']
    @block.limit = 1
    owner = create_user('block-owner').person
    @block.box = owner.boxes.last
    @block.save!
    @page = fast_create(Folder, :profile_id => @profile.id)
  end

  should 'render response error if contents is nil' do
    xhr :get, :view_content, :id => @block.id, :article_id => @page.id, :page => 1, :profile => @profile.identifier
    assert_response 500
  end

  should 'render error if page do not exists' do
    article = fast_create(TinyMceArticle, :parent_id => @page.id, :profile_id => @profile.id)
    xhr :get, :view_content, :id => @block.id, :article_id => @page.id, :page => 2, :profile => @profile.identifier
    assert_response 500
  end

  should 'replace div with content for page passed as parameter' do
    article1 = fast_create(TinyMceArticle, :parent_id => @page.id, :profile_id => @profile.id, :name => 'article1')
    article2 = fast_create(TinyMceArticle, :parent_id => @page.id, :profile_id => @profile.id, :name => 'article2')
    xhr :get, :view_content, :id => @block.id, :article_id => @page.id, :page => 2, :profile => @profile.identifier
    assert_response :success
    assert_match /context_content_#{@block.id}/, @response.body
    assert_match /context_content_more_#{@block.id}/, @response.body
    assert_match /article2/, @response.body
  end

  should 'do not render pagination buttons if it has only one page' do
    article1 = fast_create(TinyMceArticle, :parent_id => @page.id, :profile_id => @profile.id, :name => 'article1')
    xhr :get, :view_content, :id => @block.id, :article_id => @page.id, :page => 2, :profile => @profile.identifier
    assert_no_match /context_content_more_#{@block.id}/, @response.body
  end

end
