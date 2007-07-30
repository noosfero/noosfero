require File.dirname(__FILE__) + '/../test_helper'
require 'enterprise_controller'

# Re-raise errors caught by the controller.
class EnterpriseController; def rescue_action(e) raise e end; end

class EnterpriseControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = EnterpriseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as('ze')
  end

  def test_index
    get :index
    assert_response :success

    assert_kind_of Array, assigns(:my_enterprises)
    
    assert_kind_of Array, assigns(:pending_enterprises)
  end

  
end
