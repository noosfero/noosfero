require "#{File.dirname(__FILE__)}/../../test_helper"

class OrdersCyclePlugin::CycleControllerTest < Test::Unit::TestCase

  def setup
    @controller = OrdersCyclePluginCycleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'create a new cycle' do
  end

end
