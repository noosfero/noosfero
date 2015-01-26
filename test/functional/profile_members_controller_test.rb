require_relative "../test_helper"
require 'profile_members_controller'

# Re-raise errors caught by the controller.
class ProfileMembersController; def rescue_action(e) raise e end; end

class ProfileMembersControllerTest < ActionController::TestCase
  def setup
    super
    @controller = ProfileMembersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'not access index if dont have permission' do
    user = create_user('test_user')
    fast_create(Enterprise, :identifier => 'test_enterprise', :name => 'test enterprise')
    login_as :test_user

    get 'index', :profile => 'test_enterprise'

    assert_response 403
    assert_template 'access_denied'
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
    assert_template :layout => nil
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

  should 'display send email to members that have the permission' do
    community = Community.create!(:name => 'Test Com', :identifier => 'test_com')
    person = create_user_with_permission('test_user', 'manage_memberships', community)
    give_permission(person, 'send_mail_to_members', community)
    login_as :test_user

    get :index, :profile => community.identifier
    assert_tag :tag => 'a', :attributes => {:href => /send_mail/}
  end

  should 'not display send email to members if doesn\'t have the permission' do
    community = Community.create!(:name => 'Test Com', :identifier => 'test_com')
    person = create_user_with_permission('test_user', 'manage_memberships', community)
    login_as :test_user

    get :index, :profile => community.identifier
    assert_no_tag :tag => 'a', :attributes => {:href => /send_mail/}
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

  should 'list users on search by role' do
    e = Enterprise.create!(:name => 'Sample Enterprise', :identifier => 'sample-enterprise')
    user = create_user_with_permission('test_user', 'manage_memberships', e)
    login_as :test_user

    # Should list if match name
    p1 = create_user('person_1').person
    p2 = create_user('person_2').person
    # Should not list if don't match name
    p3 = create_user('blo').person
    r1 = Profile::Roles.organization_member_roles(e.environment.id).first
    r2 = Profile::Roles.organization_member_roles(e.environment.id).last

    p4 = create_user('person_4').person
    e.affiliate(p4, r1)
    p5 = create_user('person_5').person
    e.affiliate(p5, r2)

    # Should be case insensitive
    p6 = create_user('PeRsOn_2').person
    # Should list if match identifier
    p7 = create_user('person_7').person
    p7.name = 'Bli'
    p7.save!

    get :search_user, :profile => e.identifier, 'q_'+r1.key => 'per', :role => r1.id
    assert_match /#{p1.name}/, @response.body
    assert_match /#{p2.name}/, @response.body
    assert_no_match /#{p3.name}/, @response.body
    assert_no_match /#{p4.name}/, @response.body
    assert_match /#{p5.name}/, @response.body
    assert_match /#{p6.name}/, @response.body
    assert_match /#{p7.name}/, @response.body

    get :search_user, :profile => e.identifier, 'q_'+r2.key => 'per', :role => r2.id
    assert_match /#{p1.name}/, @response.body
    assert_match /#{p2.name}/, @response.body
    assert_no_match /#{p3.name}/, @response.body
    assert_match /#{p4.name}/, @response.body
    assert_no_match /#{p5.name}/, @response.body
    assert_match /#{p6.name}/, @response.body
    assert_match /#{p7.name}/, @response.body
  end

  should 'save associations' do
    e = Enterprise.create!(:name => 'Sample Enterprise', :identifier => 'sample-enterprise')
    user = create_user_with_permission('test_user', 'manage_memberships', e)
    login_as :test_user

    p1 = create_user('person-1').person
    p2 = create_user('person-2').person
    p3 = create_user('person-3').person
    roles = Profile::Roles.organization_member_roles(e.environment.id)
    r1 = roles.first
    r2 = roles.last
    roles.delete(r1)
    roles.delete(r2)

    roles_params = roles.inject({}) { |result, role| result.merge({'q_'+role.key => ''})}

    post  :save_associations,
          {:profile => e.identifier,
          'q_'+r1.key => "#{p1.id},#{p2.id},#{user.id}",
          'q_'+r2.key => "#{p2.id},#{p3.id}"}.merge(roles_params)
    assert_includes e.members_by_role(r1), p1
    assert_includes e.members_by_role(r1), p2
    assert_not_includes e.members_by_role(r1), p3
    assert_not_includes e.members_by_role(r2), p1
    assert_includes e.members_by_role(r2), p2
    assert_includes e.members_by_role(r2), p3

    post  :save_associations,
          {:profile => e.identifier,
          'q_'+r1.key => "#{p2.id},#{p3.id},#{user.id}",
          'q_'+r2.key => "#{p1.id},#{p2.id}"}.merge(roles_params)
    assert_not_includes e.members_by_role(r1), p1
    assert_includes e.members_by_role(r1), p2
    assert_includes e.members_by_role(r1), p3
    assert_includes e.members_by_role(r2), p1
    assert_includes e.members_by_role(r2), p2
    assert_not_includes e.members_by_role(r2), p3
  end

  should 'ignore roles with id zero' do
    ent = fast_create(Enterprise, :name => 'Test Ent', :identifier => 'test_ent')
    p = create_user_with_permission('test_user', 'manage_memberships', ent)
    login_as :test_user
    r = ent.environment.roles.create!(:name => 'test_role', :permissions => ['edit_profile'])
    get :update_roles, :profile => ent.identifier, :person => p.id, :roles => ["0", r.id, nil]

    p_roles = p.find_roles(ent).map(&:role).uniq

    assert_equal [r], p_roles
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
