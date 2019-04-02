require_relative '../test_helper'

class RoleControllerTest < ActionDispatch::IntegrationTest
  all_fixtures

  def setup
    @role = Role.first
    login_as_rails5(create_admin_user(Environment.default))
  end

  def test_index_should_get_roles
    get role_index_path
    assert_response :success
    assert assigns(:roles)
  end

  def test_show_should_fetch_role
    get role_path(@role)
    assert_response :success
    assert_template 'show'
    assert assigns(:role)
    assert_equal @role.id, assigns(:role).id
  end

  def test_can_edit
    get edit_role_path(@role)
    assert_not_nil assigns(:role)
    assert_equal @role.id, assigns(:role).id
  end

  def test_should_update_to_valid_parameters
    Role.any_instance.stubs(:valid?).returns(true)
    put role_path(@role)
    assert_response :redirect
    assert_not_nil assigns(:role)
  end

  def test_should_not_update_to_invalid_parameters
    Role.any_instance.stubs(:valid?).returns(false)
    put role_path(@role)
    assert_response :success
    assert_not_nil assigns(:role)
    assert_not_nil session[:notice]
  end

  def test_should_see_new_role_page
    get new_role_path
    assert_response :success
    assert_not_nil assigns(:role)
  end

  def test_should_create_new_role
    assert_difference 'Role.count' do
      post role_index_path, params: {:role => { :name => 'Test Role', :permissions => ["test"] }}
    end
    assert_redirected_to :action => 'show', :id => Role.last.id
  end

  def test_should_not_create_new_role
    assert_no_difference 'Role.count' do
      post role_index_path, params: {:role => { }}
    end
    assert_template :new
  end

  should 'not crash when editing role with no permissions' do
    role = Role.create!(:name => 'test_role', :environment => Environment.default)

    assert_nothing_raised do
      get edit_role_path(role)
    end
  end

  should 'display permissions for both environment and profile when editing a environment role' do
    role = Role.create!(:name => 'environment_role', :key => 'environment_role', :environment => Environment.default)
    get edit_role_path(role)
    ['Environment', 'Profile'].each do |key|
      ApplicationRecord::PERMISSIONS[key].each do |permission, value|
        assert_select ".permissions.#{key.downcase} input##{permission}"
      end
    end
  end

  should 'display permissions only for profile when editing a profile role' do
    role = Role.create!(:name => 'profile_role', :key => 'profile_role', :environment => Environment.default)
    get edit_role_path(role)
    ApplicationRecord::PERMISSIONS['Profile'].each do |permission, value|
      assert_select "input##{permission}"
    end
    assert_select ".permissions.environment", false
  end

end
