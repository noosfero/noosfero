require "#{File.dirname(__FILE__)}/../test_helper"

class ManageTagsTest < ActionController::IntegrationTest
  fixtures :tags, :profiles, :users, :virtual_communities, :domains, :boxes, :blocks

  def test_tags_create_edit_destroy
    get '/admin/manage_tags'
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert_equal '/admin/manage_tags/list', path
    assert_tag :tag => 'a', :attributes => {:href => '/admin/manage_tags/new'}

    get '/admin/manage_tags/new'
    assert_response :success
    assert_tag :tag => 'input', :attributes => {:name => 'tag[name]'}
    assert_tag :tag => 'select', :attributes => {:name => 'tag[parent_id]'}
    assert_tag :tag => 'input', :attributes => {:name => 'tag[pending]'}

    post '/admin/manage_tags/create', :tag => { 'name' => 'new_tag', 'pending' => 'false', 'parent_id' => '0'}
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert_equal '/admin/manage_tags/list', path
  end

end
