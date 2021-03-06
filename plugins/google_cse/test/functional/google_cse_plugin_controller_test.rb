require "test_helper"
require_relative "../../controllers/google_cse_plugin_controller"

class GoogleCsePluginControllerTest < ActionController::TestCase
  def setup
    @controller = GoogleCsePluginController.new
  end

  should "get results page" do
    get :results
    assert_response :success
  end
end
