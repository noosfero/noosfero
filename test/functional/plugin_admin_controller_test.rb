require_relative "../test_helper"

class PluginAdminController
  def index
    render :text => 'ok'
  end
end

class PluginAdminControllerTest < ActionController::TestCase

  should 'allow user with the required permission to access plugin administration page' do
    create_user_with_permission('testuser', 'edit_environment_features', Environment.default)
    login_as('testuser')
    get :index
    assert_response :success
  end

  should 'forbid access to users that did not have the required permission' do
    create_user('testuser')
    login_as('testuser')
    get :index
    assert_response :forbidden
  end

end
