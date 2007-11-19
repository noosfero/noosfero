require File.dirname(__FILE__) + '/../test_helper'
require 'manage_products_controller'

# Re-raise errors caught by the controller.
class ManageProductsController; def rescue_action(e) raise e end; end

class ManageProductsControllerTest < Test::Unit::TestCase
  def setup
    @controller = ManageProductsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
