require File.dirname(__FILE__) + '/../test_helper'
require 'profile_member_controller'

# Re-raise errors caught by the controller.
class ProfileMemberController; def rescue_action(e) raise e end; end

class ProfileMemberControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProfileMemberController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
