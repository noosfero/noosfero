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

  def test_logged_index
    login_as 'ze'
    get :index
    assert_response :redirect

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
  
end
