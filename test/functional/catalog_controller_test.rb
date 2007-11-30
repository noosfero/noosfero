require File.dirname(__FILE__) + '/../test_helper'
require 'catalog_controller'

# Re-raise errors caught by the controller.
class CatalogController; def rescue_action(e) raise e end; end

class CatalogControllerTest < Test::Unit::TestCase
  def setup
    @controller = CatalogController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
