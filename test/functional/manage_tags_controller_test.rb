require File.dirname(__FILE__) + '/../test_helper'
require 'manage_tags_controller'

# Re-raise errors caught by the controller.
class ManageTagsController; def rescue_action(e) raise e end; end

class ManageTagsControllerTest < Test::Unit::TestCase

  def test_truth
    assert true
  end

#TODO i comment it because the test were not passing
  fixtures :tags, :users, :blocks, :profiles, :virtual_communities, :boxes, :domains
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
    assert_nothing_raised { Tag.find(1) }
    get :list, :parent => Tag.find(1)
    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:parent), 'the list should be scoped'
    assert_not_nil assigns(:tags)
    assert_not_nil assigns(:pending_tags)
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
    assert_nothing_raised { Tag.find(1) }
    get :edit, :id => 1
    assert assigns(:tag)
    assert assigns(:parent_tags)
  end

  def test_update
    assert_nothing_raised { Tag.find(1) }
    post :update, :id => 1, :tag => {:name => 'altered_tag'}
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert assigns(:tag)
  end

  def test_update_wrong
    assert_nothing_raised { Tag.find(1) }
    post :update, :id => 1, :tag => {:name => ''}
    assert_response :success
    assert_template 'edit'
    assert assigns(:parent_tags)
  end

  def test_destroy
    assert_nothing_raised { Tag.find(1) }
    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_not_nil flash[:notice]
    assert_raise(ActiveRecord::RecordNotFound) { Tag.find(1) }
  end

  def test_approve
    assert_nothing_raised { Tag.find_with_pendings(4) }
    assert Tag.find_with_pendings(4).pending?
    post :approve, :id => 4
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert ( not Tag.find_with_pendings(4).pending? )
  end
end
