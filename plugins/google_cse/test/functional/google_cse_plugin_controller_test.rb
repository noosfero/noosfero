require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/google_cse_plugin_controller'

class GoogleCsePluginControllerTest < ActionController::TestCase

  def setup
    @controller = GoogleCsePluginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'get results page' do
    get :results
    assert_response :success
  end

end
