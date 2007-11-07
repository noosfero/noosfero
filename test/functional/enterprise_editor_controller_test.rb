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
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'Test enteprise')
    get 'index', :profile => 'test_enterprise'

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
    user = create_user('test_user').person
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'Test enterprise')
    role = Role.create!(:name => 'test_role', :permissions => ['edit_profile'])
    assert user.add_role(role, ent)
    assert user.has_permission?('edit_profile', ent)
    login_as :test_user

    get 'index', :profile => 'test_enterprise'

    assert_response :success
    assert @controller.send(:profile)
    assert_template 'index'
  end
end
