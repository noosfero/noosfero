require File.dirname(__FILE__) + '/../test_helper'
require 'profile_members_controller'

# Re-raise errors caught by the controller.
class ProfileMembersController; def rescue_action(e) raise e end; end

class ProfileMembersControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProfileMembersController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
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
    assert_includes assigns(:roles), role
    assert_equal member, assigns('member')
    assert_template 'change_role'
    assert_tag :tag => 'input', :attributes => { :type => 'checkbox', :name => 'roles[]'}
    assert_tag :tag => 'label', :content => role.name
  end

  should 'update roles' do
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'test enterprise')
    role1 = Role.create!(:name => 'member_role', :permissions => ['edit_profile'], :environment => ent.environment)
    role2 = Role.create!(:name => 'owner_role', :permissions => ['edit_profile', 'destroy_profile'], :environment => ent.environment)

    member = create_user('test_member').person
    member.add_role(role1, ent)
    user = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    post 'update_roles', :profile => 'test_enterprise', :roles => [role2.id], :person => member

    assert_response :redirect
    member = Person.find(member.id)
    roles = member.find_roles(ent).map(&:role)
    assert_includes  roles, role2
    assert_not_includes roles, role1
  end

  should 'unassociate community member' do
    com = Community.create!(:identifier => 'test_community', :name => 'test community')
    admin = create_user_with_permission('admin_user', 'manage_memberships', com)
    member = create_user('test_member').person
    com.add_member(member)
    assert_includes com.members, member

    login_as :admin_user
    get :unassociate, :profile => com.identifier, :id => member

    assert_response :redirect
    assert_redirected_to :action => 'index'
    member.reload
    com.reload
    assert_not_includes com.members, member
  end

end
