require File.dirname(__FILE__) + '/../test_helper'
require 'role_controller'

# Re-raise errors caught by the controller.
class RoleController; def rescue_action(e) raise e end; end

class RoleControllerTest < Test::Unit::TestCase
  def setup
    @controller = RoleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  all_fixtures

  def test_index_should_get_roles
    get 'index'
    assert assigns(:roles)
  end

  def test_show_should_fetch_role
    get 'show', :id => 1
    assert assigns(:role)
    assert_equal 1, assigns(:role).id 
  end

  def test_should_create_with_valid_paramters
    Role.any_instance.stubs(:valid?).returns(true)
    post 'create'
    assert !assigns(:role).new_record?
    assert_nil flash[:notice]
    assert_response :redirect
  end
  
  def test_should_not_create_with_invalid_paramters
    Role.any_instance.stubs(:valid?).returns(false)
    post 'create'
    assert assigns(:role).new_record?
    assert_not_nil flash[:notice]
    assert_response :success
  end

  def test_can_edit
    get 'edit', :id => 1
    assert_not_nil assigns(:role)
    assert_equal 1, assigns(:role).id 
  end

  def test_should_update_to_valid_parameters
    Role.any_instance.stubs(:valid?).returns(true)
    post 'update', :id => 1
    assert_not_nil assigns(:role)
    assert_nil flash[:notice]
    assert_response :redirect
  end
  
  def test_should_not_update_to_invalid_paramters
    Role.any_instance.stubs(:valid?).returns(false)
    post 'update', :id => 1
    assert_not_nil assigns(:role)
    assert_not_nil flash[:notice]
    assert_response :success
  end

  def test_should_destroy
    assert_difference Role, :count, -1 do
      post 'destroy', :id => 1
      assert_not_nil assigns(:role)
    end
  end
end
