require File.dirname(__FILE__) + '/../test_helper'
require 'enterprise_editor_controller'

# Re-raise errors caught by the controller.
class EnterpriseEditorController; def rescue_action(e) raise e end; end

class EnterpriseEditorControllerTest < Test::Unit::TestCase
  def setup
    @controller = EnterpriseEditorController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'not see index if do not logged in' do
    ent1 = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    get 'index', :profile => 'test_enterprise1'

    assert_response :success
    assert_template 'access_denied.rhtml'
  end

  should 'not see index if do not have permission to edit profile' do
    user = create_user('test_user')
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'Test enteprise')
    login_as :test_user

    get 'index', :profile => 'test_enterprise'

    assert_response :success
    assert @controller.send(:profile)
    assert_equal ent.identifier, @controller.send(:profile).identifier
    assert_template 'access_denied.rhtml'
  end

  should 'see index if have permission' do
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'Test enterprise')
    user = create_user('test_user').person
    role = Role.create!(:name => 'test_role', :permissions => ['edit_profile'])
    assert user.add_role(role, ent)
    assert user.has_permission?('edit_profile', ent)
    login_as :test_user

    assert_equal ent, Profile.find_by_identifier('test_enterprise')

    get 'index', :profile => 'test_enterprise'

    assert_response :success
    assert_equal ent, @controller.send(:profile)
    assert_equal user, @controller.send(:user)
    assert_template 'index'
  end

  should 'show the edit form' do
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'Test enterprise')
    user = create_user_with_permission('test_user', 'edit_profile', ent)
    login_as :test_user

    get 'edit', :profile => 'test_enterprise'

    assert_response :success
    assert_equal ent, @controller.send(:profile)
    assert_template 'edit'
  end

  should 'update' do
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'Test enterprise')
    user = create_user_with_permission('test_user', 'edit_profile', ent)
    login_as :test_user

    post 'update', :profile => 'test_enterprise', :enterprise => {:name => 'test_name'}

    assert_response :redirect
    assert_redirected_to :action => 'index'
    ent.reload
    assert_equal 'test_name',  ent.name
  end

  should 'destroy' do
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'Test enterprise')
    user = create_user_with_permission('test_user', 'destroy_profile', ent)
    login_as :test_user

    post 'destroy', :profile => 'test_enterprise'
    
    assert_response :redirect
    assert_redirected_to :controller => 'profile_editor', :profile => 'test_user'
  end
end
