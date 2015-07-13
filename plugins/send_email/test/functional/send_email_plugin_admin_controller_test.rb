require 'test_helper'

class SendEmailPluginAdminControllerTest < ActionController::TestCase

  def setup
    @admin = create_user('adminplug').person
    @environment = @admin.environment
    @environment.add_admin(@admin)
  end

  should 'deny access to guests and redirect to login' do
    get :index
    assert_response :redirect
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  should 'allow access to admin' do
    login_as @admin.identifier
    get :index
    assert_response :success
  end

  should 'deny access to ordinary users' do
    @user = create_user('normaluser').person
    login_as @user.identifier
    get :index
    assert_response 403
  end

end
