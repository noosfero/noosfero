require "#{File.dirname(__FILE__)}/../../test_helper"

class OrdersCyclePlugin::OrderControllerTest < Test::Unit::TestCase

  def setup
    @controller = OrdersCyclePluginOrderController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end


end
