require File.dirname(__FILE__) + '/../test_helper'
require 'environment_design_controller'

# Re-raise errors caught by the controller.
class EnvironmentDesignController; def rescue_action(e) raise e end; end

class EnvironmentDesignControllerTest < Test::Unit::TestCase
  def setup
    @controller = EnvironmentDesignController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
