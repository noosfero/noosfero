require File.dirname(__FILE__) + '/../test_helper'
require 'profile_admin_controller'

# Re-raise errors caught by the controller.
class ProfileAdminController; def rescue_action(e) raise e end; end

class ProfileAdminControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProfileAdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
