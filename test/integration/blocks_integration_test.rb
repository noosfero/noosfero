require "#{File.dirname(__FILE__)}/../test_helper"

class BlocksIntegrationTest < ActionController::IntegrationTest

  should "allow blog as block content" do
    profile = fast_create(Profile)
    blog = fast_create(Blog, :name => 'Blog', :profile_id => profile.id)
    post = fast_create(TinyMceArticle, :name => "A Post", :profile_id => profile.id, :parent_id => blog.id, :body => 'Lorem ipsum dolor sit amet')
    block = ArticleBlock.new
    block.article = blog
    profile.boxes << Box.new
    profile.boxes.first.blocks << block
    
    get "/profile/#{profile.identifier}"
    assert_match(/Lorem ipsum dolor sit amet/, @response.body)
  end

end
