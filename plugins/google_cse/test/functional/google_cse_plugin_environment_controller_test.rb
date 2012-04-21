require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/google_cse_plugin_environment_controller'

# Re-raise errors caught by the controller.
class GoogleCsePluginEnvironmentController; def rescue_action(e) raise e end; end

class GoogleCsePluginEnvironmentControllerTest < ActionController::TestCase

  def setup
    @controller = GoogleCsePluginEnvironmentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'get results page' do
    get :results
    assert_response :success
  end

end
