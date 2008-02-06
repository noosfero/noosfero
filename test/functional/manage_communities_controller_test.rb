require File.dirname(__FILE__) + '/../test_helper'
require 'manage_communities_controller'

# Re-raise errors caught by the controller.
class ManageCommunitiesController; def rescue_action(e) raise e end; end

class ManageCommunitiesControllerTest < Test::Unit::TestCase
  def setup
    @controller = ManageCommunitiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
