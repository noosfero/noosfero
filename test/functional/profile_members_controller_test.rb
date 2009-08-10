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
    role = Role.create!(:name => 'member_role', :environment => Environment.default, :permissions => ['edit_profile'])
    member = create_user('test_member').person
    member.add_role(role, ent)
    user = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    get 'change_role', :profile => 'test_enterprise' , :id => member.id

    assert_response :success
    assert_includes assigns(:roles), role
    assert_equal member, assigns('member')
    assert_template 'change_role'
    assert_tag :tag => 'input', :attributes => { :type => 'checkbox', :name => 'roles[]'}
    assert_tag :tag => 'label', :content => role.name
  end

  should 'not show form to change role if person is not member' do
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'test enterprise')
    not_member = create_user('test_member').person
    user = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    get 'change_role', :profile => 'test_enterprise' , :id => not_member.id

    assert_nil assigns('member')
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  should 'update roles' do
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'test enterprise')
    role1 = Role.create!(:name => 'member_role', :permissions => ['edit_profile'], :environment => ent.environment)
    role2 = Role.create!(:name => 'owner_role', :permissions => ['edit_profile', 'destroy_profile'], :environment => ent.environment)

    member = create_user('test_member').person
    member.add_role(role1, ent)
    user = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    post 'update_roles', :profile => 'test_enterprise', :roles => [role2.id], :person => member.id

    assert_response :redirect
    member = Person.find(member.id)
    roles = member.find_roles(ent).map(&:role)
    assert_includes  roles, role2
    assert_not_includes roles, role1
  end

  should 'not update roles if user is not profile member' do
    ent = Enterprise.create!(:identifier => 'test_enterprise', :name => 'test enterprise')
    role = Role.create!(:name => 'owner_role', :permissions => ['edit_profile', 'destroy_profile'], :environment => ent.environment)

    not_member = create_user('test_member').person
    user = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    post 'update_roles', :profile => 'test_enterprise', :roles => [role.id], :person => not_member.id

    assert_response :redirect
    not_member = Person.find(not_member.id)
    roles = not_member.find_roles(ent).map(&:role)
    assert_not_includes  roles, role
  end


  should 'unassociate community member' do
    com = Community.create!(:identifier => 'test_community', :name => 'test community')
    admin = create_user_with_permission('admin_user', 'manage_memberships', com)
    member = create_user('test_member').person
    com.add_member(member)
    assert_includes com.members, member

    login_as :admin_user
    get :unassociate, :profile => com.identifier, :id => member

    assert_response :success
    assert_equal nil, @response.layout
    member.reload
    com.reload
    assert_not_includes com.members, member
  end

  should 'not list roles from other environments' do
    env2 = Environment.create!(:name => 'new env')
    role = Role.create!(:name => 'some role', :environment => env2, :permissions => ['manage_memberships'])

    com = Community.create!(:name => 'test community')
    p = create_user_with_permission('test_user', 'manage_memberships', com)
    assert_includes com.members.map(&:name), p.name

    login_as :test_user
    get :change_role, :id => p.id, :profile => com.identifier

    assert_equal p, assigns(:member)
    assert_response :success
    assert_not_includes assigns(:roles), role
  end

  should 'enterprises have a add members button' do
    ent = Enterprise.create!(:name => 'Test Ent', :identifier => 'test_ent')
    u = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    get :index, :profile => ent.identifier
    assert_tag :tag => 'a', :attributes => {:href => /add_members/}
  end

  should 'not display add members button for communities' do
    com = Community.create!(:name => 'Test Com', :identifier => 'test_com')
    u = create_user_with_permission('test_user', 'manage_memberships', com)
    login_as :test_user

    get :index, :profile => com.identifier
    assert_no_tag :tag => 'a', :attributes => {:href => /add_members/}
  end

  should 'have a add_members page' do
    ent = Enterprise.create!(:name => 'Test Ent', :identifier => 'test_ent')
    u = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    assert_nothing_raised do
      get :add_members, :profile => ent.identifier
    end

  end

  should 'list current members when adding new members' do
    ent = Enterprise.create!(:name => 'Test Ent', :identifier => 'test_ent')
    p = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    get :add_members, :profile => ent.identifier
    ent.reload
    assert_includes ent.members, p
  end

  should 'add member to profile' do
    ent = Enterprise.create!(:name => 'Test Ent', :identifier => 'test_ent')
    p = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    u = create_user('member_wannabe').person
    post :add_member, :profile => ent.identifier, :id => u.identifier
    ent.reload

    assert_includes ent.members, p
    assert_includes ent.members, u
  end

  should 'add member with all roles' do
    ent = Enterprise.create!(:name => 'Test Ent', :identifier => 'test_ent')
    p = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    u = create_user('member_wannabe').person
    post :add_member, :profile => ent.identifier, :id => u.identifier

    assert_equivalent Profile::Roles.all_roles(ent.environment).compact, u.role_assignments.find_all_by_resource_id(ent.id).map(&:role).compact
  end

  should 'not add member to community' do
    com = Community.create!(:name => 'Test Com', :identifier => 'test_com')
    p = create_user_with_permission('test_user', 'manage_memberships', com)
    login_as :test_user

    u = create_user('member_wannabe').person
    post :add_member, :profile => com.identifier, :id => u.identifier
    com.reload

    assert_not_includes com.members, u
  end

  should 'find users' do
    ent = Enterprise.create!(:name => 'Test Ent', :identifier => 'test_ent')
    user = create_user('test_user').person
    u = create_user_with_permission('ent_user', 'manage_memberships', ent)
    login_as :ent_user

    get :find_users, :profile => ent.identifier, :query => 'test*'

    assert_includes assigns(:users_found), user
  end

  should 'not appear add button for member in add members page' do
    ent = Enterprise.create!(:name => 'Test Ent', :identifier => 'test_ent')
    p = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    get :find_users, :profile => ent.identifier, :query => 'test*'

    assert_tag :tag => 'tr', :attributes => {:id => 'tr-test_user', :style => 'display:none'}
  end

  should 'return users with <query> as a prefix' do
    daniel  = create_user('daniel').person
    daniela = create_user('daniela').person

    ent = Enterprise.create!(:name => 'Test Ent', :identifier => 'test_ent')
    p = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    get :find_users, :profile => ent.identifier, :query => 'daniel'

    assert_includes assigns(:users_found), daniel
    assert_includes assigns(:users_found), daniela
  end

  should 'ignore roles with id zero' do
    ent = Enterprise.create!(:name => 'Test Ent', :identifier => 'test_ent')
    p = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user
    r = ent.environment.roles.create!(:name => 'test_role', :permissions => ['some_perm'])
    get :update_roles, :profile => ent.identifier, :person => p.id, :roles => ["0", r.id, nil]

    p_roles = p.find_roles(ent).map(&:role).uniq

    assert p_roles, [r]
  end

end
