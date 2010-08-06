require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase

  all_fixtures
  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
    @response   = ActionController::TestResponse.new
  end

  should 'not access without right permission' do
    get :index
    assert_response 403 # forbidden
  end

  should 'grant access with right permission' do
    admin_user = create_user_with_permission('admin_user', 'manage_environment_users', Environment.default)
    login_as('admin_user')

    get :index
    assert_response :success
  end

  should 'response as XML to export users' do
    admin_user = create_user_with_permission('admin_user', 'manage_environment_users', Environment.default)
    login_as('admin_user')

    get :index, :format => 'xml'
    assert_equal 'application/xml', @response.content_type
  end

  should 'response as CSV to export users' do
    admin_user = create_user_with_permission('admin_user', 'manage_environment_users', Environment.default)
    login_as('admin_user')

    get :index, :format => 'csv'
    assert_equal 'text/csv', @response.content_type
  end

end
