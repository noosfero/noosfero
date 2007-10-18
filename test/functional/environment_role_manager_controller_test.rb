require File.dirname(__FILE__) + '/../test_helper'
require 'environment_role_manager_controller'

# Re-raise errors caught by the controller.
class EnvironmentRoleManagerController; def rescue_action(e) raise e end; end

class EnvironmentRoleManagerControllerTest < Test::Unit::TestCase
  def setup
    @controller = EnvironmentRoleManagerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
