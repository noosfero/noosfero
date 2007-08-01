require "#{File.dirname(__FILE__)}/../test_helper"

class ManageTagsTest < ActionController::IntegrationTest
  fixtures :tags, :profiles, :design_boxes, :design_blocks

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
    assert_tag :tag => 'a', :attributes => {:href => %r[/admin/manage_tags/edit]}
    
    get '/admin/manage_tags/edit', :id => 1
    assert_response :success
    assert_tag :tag => 'input', :attributes => {:name => 'tag[name]'}
    assert_tag :tag => 'select', :attributes => {:name => 'tag[parent_id]'}
    assert_tag :tag => 'input', :attributes => {:name => 'tag[pending]'}

    post '/admin/manage_tags/update', :id => 1, :tag => {:name => 'bla_tag'}
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert_equal '/admin/manage_tags/list', path
    assert_tag :tag => 'a', :attributes => {:href => %r[/admin/manage_tags/destroy]}

    post '/admin/manage_tags/destroy', :id => 1
    assert_response :redirect
    
    follow_redirect!
    assert_response :success
    assert_equal '/admin/manage_tags/list', path
  end

  def test_approve_tag
    get '/admin/manage_tags/list'
    assert_response :success
    assert_tag :tag => 'a', :attributes => {:href => %r[/admin/manage_tags/approve]}

    post '/admin/manage_tags/approve', :id => 5
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert_equal '/admin/manage_tags/list', path
  end

end
