require File.dirname(__FILE__) + '/../test_helper'
require 'enterprise_controller'

# Re-raise errors caught by the controller.
class EnterpriseController; def rescue_action(e) raise e end; end

class EnterpriseControllerTest < Test::Unit::TestCase
  all_fixtures

  def setup
    @controller = EnterpriseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_logged_with_one_enterprise_index
    login_as 'ze'
    get :index
    assert_response :redirect
    assert_redirected_to :action => 'show'

    assert_kind_of Array, assigns(:my_pending_enterprises)
  end

  def test_logged_with_two_enterprises_index
    login_as 'johndoe'
    get :index
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_kind_of Array, assigns(:my_pending_enterprises)
  end

  def test_not_logged_index
    get :index
    assert_response :redirect
    assert_redirected_to :controller => 'account'
  end

  def test_my_enterprises
    login_as 'ze'
    get :index
    assert_not_nil assigns(:my_enterprises)
    assert_kind_of Array, assigns(:my_enterprises)
  end

  def test_enterprise_listing
    login_as 'ze'
    get :list
    assert_not_nil assigns(:enterprises)
    assert Array, assigns(:enterprises)
  end

  def test_enterprise_showing
    login_as 'ze'
    get :show, :id => 5
    assert_not_nil assigns(:enterprise)
    assert_kind_of Enterprise, assigns(:enterprise)
  end

  def test_register_form
    login_as 'ze'
    get :register_form
    assert_response :success
  end

  def test_register
    login_as 'ze'
    post :register, :enterprise => {:name => 'register_test', :identifier => 'register_test'}
    assert_not_nil assigns(:enterprise)
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_fail_register
    login_as 'ze'
    post :register, :enterprise => {:name => ''}
    assert_response :success
    assert !assigns(:enterprise).valid?
  end

  def test_enterprise_editing
    login_as 'ze'
    get :edit, :id => 5
    assert_not_nil assigns(:enterprise)
    assert_kind_of Enterprise, assigns(:enterprise)
  end

  def test_enterprise_updating
    login_as 'ze'
    post :update, :id => 5, :enterprise => {:name => 'colivre'}
    assert_not_nil assigns(:enterprise)
    assert_kind_of Enterprise, assigns(:enterprise)
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_enterprise_updating_wrong
    login_as 'ze'
    post :update, :id => 5, :enterprise => {:name => ''} # name can't be blank
    assert_not_nil assigns(:enterprise)
    assert_kind_of Enterprise, assigns(:enterprise)
    assert_response :success
    assert_template 'edit'
  end

  def test_affiliate
    login_as 'ze'
    post :affiliate, :id => 6
    assert assigns(:enterprise)
    assert assigns(:enterprise).people.include?(assigns(:person))
    assert assigns(:person).enterprises.include?(assigns(:enterprise))
  end

  def test_destroy
    login_as 'ze'
    c = Enterprise.count
    assert_nothing_raised { Enterprise.find(5) }
    post :destroy, :id => 5
    assert_raise ActiveRecord::RecordNotFound do
      Enterprise.find(5)
    end
    assert_equal c - 1, Enterprise.count
  end

  def test_search
    login_as 'ze'
    get :search, :query => 'bla'
    assert assigns(:tagged_enterprises)
    assert_kind_of Array, assigns(:tagged_enterprises)
  end

  def test_activate
    login_as 'ze'
    post :activate, :id => 5
    assert assigns(:enterprise)
    assert_kind_of Enterprise, assigns(:enterprise)
    assert assigns(:enterprise).active
  end
end
