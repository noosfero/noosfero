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
    fast_create(Enterprise, :identifier => 'test_enterprise', :name => 'test enterprise')
    login_as :test_user

    get 'index', :profile => 'test_enterprise'

    assert_response 403
    assert_template 'access_denied.rhtml'
  end

  should 'access index' do
    ent = fast_create(Enterprise, :identifier => 'test_enterprise', :name => 'test enterprise')
    user = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    get 'index', :profile => 'test_enterprise'

    assert_response :success
    assert_template 'index'
  end

  should 'show form to change role' do
    ent = fast_create(Enterprise, :identifier => 'test_enterprise', :name => 'test enterprise')
    role = Profile::Roles.member(Environment.default)

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
    ent = fast_create(Enterprise, :identifier => 'test_enterprise', :name => 'test enterprise')
    not_member = create_user('test_member').person
    user = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    get 'change_role', :profile => 'test_enterprise' , :id => not_member.id

    assert_nil assigns('member')
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  should 'update roles' do
    ent = fast_create(Enterprise, :identifier => 'test_enterprise', :name => 'test enterprise')
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
    ent = fast_create(Enterprise, :identifier => 'test_enterprise', :name => 'test enterprise')
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
    env2 = fast_create(Environment, :name => 'new env')
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
    ent = fast_create(Enterprise, :name => 'Test Ent', :identifier => 'test_ent')
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

  should 'not display remove button if the member is the current user' do
    com = Community.create!(:name => 'Test Com', :identifier => 'test_com')
    admin = create_user_with_permission('admin-member', 'manage_memberships', com)
    member = fast_create(Person, :name => 'just-member')
    com.add_member(member)

    login_as(admin.identifier)

    get :index, :profile => com.identifier

    assert_tag :tag => 'td', :descendant => { :tag => 'a', :attributes => {:class => /icon-remove/, :onclick => /#{member.identifier}/} }
    assert_no_tag :tag => 'td', :descendant => { :tag => 'a', :attributes => {:class => /icon-remove/, :onclick => /#{admin.identifier}/} }
  end

  should 'have a add_members page' do
    ent = fast_create(Enterprise, :name => 'Test Ent', :identifier => 'test_ent')
    u = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    assert_nothing_raised do
      get :add_members, :profile => ent.identifier
    end

  end

  should 'list current members when adding new members' do
    ent = fast_create(Enterprise, :name => 'Test Ent', :identifier => 'test_ent')
    p = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    get :add_members, :profile => ent.identifier
    ent.reload
    assert_includes ent.members, p
  end

  should 'add member to profile' do
    ent = fast_create(Enterprise, :name => 'Test Ent', :identifier => 'test_ent')
    p = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    u = create_user('member_wannabe').person
    post :add_member, :profile => ent.identifier, :id => u.id
    ent.reload

    assert_includes ent.members, p
    assert_includes ent.members, u
  end

  should 'add member with all roles' do
    ent = fast_create(Enterprise, :name => 'Test Ent', :identifier => 'test_ent')
    p = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    u = create_user('member_wannabe').person
    post :add_member, :profile => ent.identifier, :id => u.id

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
    ent = fast_create(Enterprise, :name => 'Test Ent', :identifier => 'test_ent')
    user = create_user_full('test_user').person
    person = create_user_with_permission('ent_user', 'manage_memberships', ent)
    login_as :ent_user

    get :find_users, :profile => ent.identifier, :query => 'test*', :scope => 'all_users'

    assert_includes assigns(:users_found), user
  end

  should 'not display members when finding users in all_users scope' do
    ent = fast_create(Enterprise, :name => 'Test Ent', :identifier => 'test_ent')
    user = create_user_full('test_user').person

    person = create_user_with_permission('ent_user', 'manage_memberships', ent)
    login_as :ent_user

    get :find_users, :profile => ent.identifier, :query => '*user', :scope => 'all_users'

    assert_tag :tag => 'a', :content => /#{user.name}/
    assert_no_tag :tag => 'a', :content => /#{person.name}/
  end

  should 'not display admins when finding users in new_admins scope' do
    ent = fast_create(Enterprise, :name => 'Test Ent', :identifier => 'test_ent')

    person = create_user('admin_user').person
    ent.add_admin(person)

    user = create_user_full('test_user').person
    ent.add_member(user).finish

    login_as :admin_user

    get :find_users, :profile => ent.identifier, :query => '*user', :scope => 'new_admins'

    assert_tag :tag => 'a', :content => /#{user.name}/
    assert_no_tag :tag => 'a', :content => /#{person.name}/
  end

  should 'return users with <query> as a prefix' do
    daniel  = create_user_full('daniel').person
    daniela = create_user_full('daniela').person

    ent = fast_create(Enterprise, :name => 'Test Ent', :identifier => 'test_ent')
    person = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user

    get :find_users, :profile => ent.identifier, :query => 'daniel', :scope => 'all_users'

    assert_includes assigns(:users_found), daniel
    assert_includes assigns(:users_found), daniela
  end

  should 'ignore roles with id zero' do
    ent = fast_create(Enterprise, :name => 'Test Ent', :identifier => 'test_ent')
    p = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user
    r = ent.environment.roles.create!(:name => 'test_role', :permissions => ['some_perm'])
    get :update_roles, :profile => ent.identifier, :person => p.id, :roles => ["0", r.id, nil]

    p_roles = p.find_roles(ent).map(&:role).uniq

    assert p_roles, [r]
  end

  should 'add locale on mailing' do
    community = fast_create(Community)
    admin_user = create_user_with_permission('profile_admin_user', 'manage_memberships', community)
    login_as('profile_admin_user')
    @controller.stubs(:locale).returns('pt')
    post :send_mail, :profile => community.identifier, :mailing => {:subject => 'Hello', :body => 'We have some news'}
    assert_equal 'pt', assigns(:mailing).locale
  end

  should 'save mailing' do
    community = fast_create(Community)
    admin_user = create_user_with_permission('profile_admin_user', 'manage_memberships', community)
    login_as('profile_admin_user')
    @controller.stubs(:locale).returns('pt')
    post :send_mail, :profile => community.identifier, :mailing => {:subject => 'Hello', :body => 'We have some news'}
    assert_equal ['Hello', 'We have some news'], [assigns(:mailing).subject, assigns(:mailing).body]
    assert_redirected_to :action => 'index'
  end

  should 'add the user logged on mailing' do
    community = fast_create(Community)
    admin_user = create_user_with_permission('profile_admin_user', 'manage_memberships', community)
    login_as('profile_admin_user')
    post :send_mail, :profile => community.identifier, :mailing => {:subject => 'Hello', :body => 'We have some news'}
    assert_equal Profile['profile_admin_user'], assigns(:mailing).person
  end

  should 'set a community member as admin' do
    community = fast_create(Community)
    admin = create_user_with_permission('admin_user', 'manage_memberships', community)
    member = create_user('test_member').person
    community.add_member(member)

    assert_not_includes community.admins, member

    login_as :admin_user
    get :add_admin, :profile => community.identifier, :id => member.identifier

    assert_includes community.admins, member
  end

  should 'remove a community admin' do
    community = fast_create(Community)
    admin = create_user_with_permission('admin_user', 'manage_memberships', community)
    member = create_user('test_member').person
    community.add_admin(member)

    assert_includes community.admins, member

    login_as :admin_user
    get :remove_admin, :profile => community.identifier, :id => member.identifier

    assert_not_includes community.admins, member
  end

end
