require File.dirname(__FILE__) + '/../test_helper'
require 'environment_admin_controller'

# Re-raise errors caught by the controller.
class EnvironmentAdminController; def rescue_action(e) raise e end; end

class EnvironmentAdminControllerTest < Test::Unit::TestCase
  def setup
    @controller = EnvironmentAdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
