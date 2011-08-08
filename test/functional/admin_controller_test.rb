require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase

  class AdminTestController < AdminController
    def index
      render :text => 'ok', :layout => 'application'
    end
  end

  def setup
    @controller = AdminTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'require ssl' do
    Environment.default.update_attribute(:enable_ssl, true)
    get :index
    assert_redirected_to :protocol => 'https://'
  end

  should 'detect ssl' do
    login_as 'ze'
    @request.expects(:ssl?).returns(true).at_least_once
    get :index
    assert_response :success
  end

end
