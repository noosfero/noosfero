require File.dirname(__FILE__) + '/../test_helper'
require 'profile_members_controller'

# Re-raise errors caught by the controller.
class ProfileMembersController; def rescue_action(e) raise e end; end

class ProfileMembersControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProfileMembersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
