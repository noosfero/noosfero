require File.dirname(__FILE__) + '/../test_helper'
require 'manage_tags_controller'

# Re-raise errors caught by the controller.
class ManageTagsController; def rescue_action(e) raise e end; end

class ManageTagsControllerTest < Test::Unit::TestCase

  fixtures :profiles, :design_boxes, :design_blocks, :domains

  def setup
    @controller = ManageTagsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_get_index
    get :index
    assert_response :redirect
    assert_redirected_to :action => 'list'
  end

  def test_list
    get :list
    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:tags)
    assert_not_nil assigns(:pending_tags)
    assert_nil assigns(:parent), 'the list should not scoped'
  end

  def test_scoped_list
    parent_tag = Tag.create(:name => 'parent_tag')
    child_tag = Tag.create(:name => 'child_tag', :parent => parent_tag)
    orphan_tag = Tag.create(:name => 'orphan_tag')
    get :list, :parent => parent_tag
    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:parent), 'the list should be scoped'
    assert_not_nil assigns(:tags)
    assert_not_nil assigns(:pending_tags)
    assert assigns(:tags).include?(child_tag)
    assert (not assigns(:tags).include?(orphan_tag))

  end

  def test_new
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:parent_tags)
    assert_not_nil assigns(:tag)
  end

  def test_create
    post :create, :tag => {:name => 'test_tag'}
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_not_nil assigns(:tag)
  end

  def test_create_wrong
    post :create, :tag => {:name => ''}
    assert_response :success
    assert_template 'new'
  end

  def test_edit
    tag_to_edit = Tag.create(:name => 'tag_to_edit')
    get :edit, :id => tag_to_edit.id
    assert assigns(:tag)
    assert assigns(:parent_tags)
  end

  def test_update
    tag_to_update = Tag.create(:name => 'tag_to_update')
    post :update, :id => tag_to_update.id, :tag => {:name => 'altered_tag'}
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert assigns(:tag)
    assert_equal 'altered_tag', assigns(:tag).name
  end

  def test_update_wrong
    wrong_tag = Tag.create(:name => 'wrong_tag')
    post :update, :id => wrong_tag, :tag => {:name => ''}
    assert_response :success
    assert_template 'edit'
    assert assigns(:parent_tags)
  end

  def test_destroy
    destroyed_tag = Tag.create(:name => 'tag_to_destroy')
    post :destroy, :id => destroyed_tag.id
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_not_nil flash[:notice]
    assert_raise(ActiveRecord::RecordNotFound) { Tag.find(destroyed_tag.id) }
  end

  def test_approve
    pending_tag = Tag.create(:name => 'pending_tag', :pending => true)
    post :approve, :id => pending_tag.id
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert ( not Tag.find(pending_tag.id).pending? )
  end

  def test_search
    found_tag = Tag.create(:name => 'found_tag')
    lost_tag = Tag.create(:name => 'lost_tag')
    post :search, :query => 'found_tag'
    assert_not_nil assigns(:tags_found)
    assert assigns(:tags_found).include?(found_tag)
    assert (not assigns(:tags_found).include?(lost_tag))
  end
end
