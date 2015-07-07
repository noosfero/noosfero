require_relative "../test_helper"
require 'environment_role_manager_controller'

class EnvironmentRoleManagerControllerTest < ActionController::TestCase
  def setup
    @controller = EnvironmentRoleManagerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

end
