require File.join(File.dirname(__FILE__), 'test_helper')

class PermissionCheckTest < ActionController::TestCase

  def setup
    @controller = AccessControlTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_access_denied
    get :index
    assert_response 403
    assert_template 'shared/access_denied'
  end

  def test_specific_permission_granted
    user = AccessControlTestAccessor.create!(:name => 'other_user')
    role = Role.create!(:name => 'other_role', :permissions => ['do_some_stuff'])
    resource = AccessControlTestResource.create!(:name => 'some_resource')
    assert user.add_role(role, resource)
    assert user.has_permission?('do_some_stuff', resource)

    get :other_stuff, :user => user.id, :resource => resource.id
    assert_response :success
    assert_template nil
  end

  def test_try_render_shared_access_denied_view
    File.expects(:exists?).with(File.join(Rails.root, 'app', 'views', 'access_control', 'access_denied.html.erb'))
    File.expects(:exists?).with(File.join(Rails.root, 'app', 'views', 'shared', 'access_denied.html.erb'))
    AccessControlTestController.access_denied_template_path
  end

  def test_allow_access_to_user_with_one_of_multiple_permissions
    user = AccessControlTestAccessor.create!(:name => 'other_user')
    role = Role.create!(:name => 'other_role', :permissions => ['permission1'])
    resource = AccessControlTestResource.create!(:name => 'some_resource')
    assert user.add_role(role, resource)
    assert user.has_permission?('permission1', resource)

    get :stuff_with_multiple_permission, :user => user.id, :resource => resource.id
    assert_response :success
  end

end
