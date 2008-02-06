require File.dirname(__FILE__) + '/../test_helper'
require 'environment_design_controller'

# Re-raise errors caught by the controller.
class EnvironmentDesignController; def rescue_action(e) raise e end; end

class EnvironmentDesignControllerTest < Test::Unit::TestCase
  def setup
    @controller = EnvironmentDesignController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'indicate only actual blocks as such' do
    assert(@controller.available_blocks.all? {|item| item.new.is_a? Block})
  end
end
