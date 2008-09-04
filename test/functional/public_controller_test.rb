require File.dirname(__FILE__) + '/../test_helper'
require 'public_controller'

# Re-raise errors caught by the controller.
class PublicController; def rescue_action(e) raise e end; end

class PublicControllerTest < Test::Unit::TestCase

  class TestingPublicStuffController < PublicController
    def index
      render :text => 'test', :layout => false
    end
  end

  def setup
    @controller = TestingPublicStuffController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  should 'refuse SSL' do
    get :index
    assert_redirected_to :protocol => 'http://'
  end

end
