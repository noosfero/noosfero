require File.dirname(__FILE__) + '/../test_helper'
require 'profile_members_controller'

# Re-raise errors caught by the controller.
class ProfileMembersController; def rescue_action(e) raise e end; end

class ProfileMembersControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProfileMembersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_local_files_reference
    user = create_user('test_user').person
    assert_local_files_reference :get, :index, :profile => user.identifier
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  should 'not access index if dont have permission' do
    user = create_user('test_user')
    Enterprise.create!(:identifier => 'test_enterprise', :name => 'test enterprise')
    login_as :test_user

    get 'index', :profile => 'test_enterprise'

    assert_response 403
    assert_template 'access_denied.rhtml'
  end

  should 'access index' do
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'test enterprise')
    user = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    get 'index', :profile => 'test_enterprise'

    assert_response :success
    assert_template 'index'
  end

  should 'show form to change role' do
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'test enterprise')
    role = Role.create!(:name => 'member_role', :permissions => ['edit_profile'])
    member = create_user('test_member').person
    member.add_role(role, ent)
    user = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    get 'change_role', :profile => 'test_enterprise' , :id => member

    assert_response :success
    assert_equal member, assigns('member')
    assert_template 'change_role'
  end

  should 'update roles' do
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'test enterprise')
    role = Role.create!(:name => 'member_role', :permissions => ['edit_profile'])
    orole = Role.create!(:name => 'owner_role', :permissions => ['edit_profile', 'destroy_profile'])

    member = create_user('test_member').person
    member.add_role(role, ent)
    user = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    post 'update_roles', :profile => 'test_enterprise', :roles => [orole.id], :person => member

    assert_response :redirect
    member.reload
    assert member.find_roles(ent).map(&:role).include?(orole)
    assert !member.find_roles(ent).map(&:role).include?(role)

    
  end
end
