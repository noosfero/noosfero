require 'test_helper'

class SendEmailPluginAdminControllerTest < ActionDispatch::IntegrationTest

  def setup
    @admin = create_user('adminplug').person
    @environment = @admin.environment
    @environment.add_admin(@admin)
  end

  should 'deny access to guests and redirect to login' do
    get send_email_plugin_admin_path(action: :index)
    assert_response :redirect
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  should 'allow access to admin' do
    login_as_rails5 @admin.identifier
    get send_email_plugin_admin_path(action: :index)
    assert_response :success
  end

  should 'deny access to ordinary users' do
    @user = create_user('normaluser').person
    login_as_rails5 @user.identifier
    get send_email_plugin_admin_path(action: :index)
    assert_response 403
  end

end
