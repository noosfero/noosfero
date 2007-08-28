require File.dirname(__FILE__) + '/../test_helper'
require 'cms_controller'

# Re-raise errors caught by the controller.
class CmsController; def rescue_action(e) raise e end; end

class CmsControllerTest < Test::Unit::TestCase
  def setup
    @controller = CmsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
