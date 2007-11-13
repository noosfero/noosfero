require File.dirname(__FILE__) + '/../test_helper'
require 'system_admin_controller'

# Re-raise errors caught by the controller.
class SystemAdminController; def rescue_action(e) raise e end; end

class SystemAdminControllerTest < Test::Unit::TestCase
  def setup
    @controller = SystemAdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
