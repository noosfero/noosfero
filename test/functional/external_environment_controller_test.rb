require_relative '../test_helper'
require 'external_environments_controller'
include ExternalEnvironmentUpdater

class ExternalEnvironmentsControllerTest < ActionController::TestCase
  all_fixtures
  def setup
    @controller = ExternalEnvironmentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ExternalEnvironment.destroy_all
    @external_environment = ExternalEnvironment.create!(name: 'Test', url: 'test.org',
                                                  identifier: 'Testing')
    login_as(create_admin_user(Environment.default))
  end

  should 'list external environments' do
    get :index
    assert_response :success
    assert_template 'index'
    assert assigns(:environments)
  end

  should 'save external environments' do
    post :save_environments, environment: { external_environment_ids: [@external_environment] }
    assert_response 302
    assert_redirected_to controller: 'external_environments', action: 'index'
    assert Environment.default.external_environments, @external_environment
    assert_equal 'External environments updated successfully.', session[:notice]
  end

  should 'not allow non admin user to update external environments' do
    login_as('johndoe')
    post :save_environments, environment: { external_environment_ids: [@external_environment] }
    assert_response 403
  end
end
