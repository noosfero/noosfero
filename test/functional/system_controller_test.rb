require_relative "../test_helper"
require 'system_controller'

class SystemControllerTest < ActionController::TestCase
  def setup
    @controller = SystemController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
