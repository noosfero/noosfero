require_relative "../test_helper"
require 'memberships_controller'


# Re-raise errors caught by the controller.
class MembershipsController; def rescue_action(e) raise e end; end

class MembershipsControllerTest < ActionController::TestCase

  include ApplicationHelper

  def setup
    @controller = MembershipsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testuser').person
    login_as('testuser')
  end
  attr_reader :profile

  should 'list current memberships' do
    get :index, :profile => profile.identifier

    assert assigns(:memberships)
  end

  should 'present new community form' do
    get :new_community, :profile => profile.identifier
    assert_response :success
    assert_template 'new_community'
  end

  should 'be able to create a new community' do
    assert_difference 'Community.count' do
      post :new_community, :profile => profile.identifier, :community => { :name => 'My shiny new community', :description => 'This is a community devoted to anything interesting we find in the internet '}
      assert_response :redirect

      assert Community.find_by_identifier('my-shiny-new-community').members.include?(profile), "Creator user should be added as member of the community just created"
    end
  end

  should 'link to new community creation in index' do
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/memberships/new_community" }
  end

  should 'filter html from name' do
    login_as(profile.identifier)
    post :new_community, :profile => profile.identifier, :community => { :name => '<b>new</b> community' }
    assert_sanitized assigns(:community).name
  end

  should 'filter html from description' do
    login_as(profile.identifier)
    post :new_community, :profile => profile.identifier, :community => { :name => 'new community', :description => '<b>new</b> community' }
    assert_sanitized assigns(:community).description
  end

  should 'show number of members on list' do
    community = Community.create!(:name => 'my test community')
    community.add_member(profile)
    get :index, :profile => profile.identifier
    assert_tag :tag => 'li', :content => /Members: 1/
  end

  should 'show description on list' do
    community = Community.create!(:name => 'my test community', :description => 'description test')
    community.add_member(profile)
    get :index, :profile => profile.identifier
    assert_tag :tag => 'li', :content => /Description: description test/
  end

  should 'not show description to enterprises on list' do
    enterprise = fast_create(Enterprise, :identifier => 'enterprise-test', :name => 'my test enterprise')
    enterprise.add_member(profile)
    get :index, :profile => profile.identifier
    assert_no_tag :tag => 'li', :content => /Description:/
  end

  should 'show link to leave from community with reload' do
    community = Community.create!(:name => 'my test community', :description => 'description test')
    community.add_member(profile)
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/profile/#{community.identifier}/leave?reload=true" }, :content => 'Leave community'
  end

  should 'current user is added as admin after create new community' do
    post :new_community, :profile => profile.identifier, :community => { :name => 'My shiny new community', :description => 'This is a community devoted to anything interesting we find in the internet '}
    assert_equal Profile::Roles.admin(profile.environment.id), profile.find_roles(Community.find_by_identifier('my-shiny-new-community')).first.role
  end

  should 'display button to create community' do
    get :index, :profile => 'testuser'
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/testuser/memberships/new_community" }
  end

  should 'display destroy link only to communities' do
    community = Community.create!(:name => 'A community to destroy')
    enterprise = fast_create(Enterprise, :name => 'A enterprise test')

    person = Person['testuser']
    community.add_admin(person)
    enterprise.add_admin(person)

    get :index, :profile => 'testuser'

    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{community.identifier}/profile_editor/destroy_profile" }
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{enterprise.identifier}/profile_editor/destroy_profile" }
  end

  should 'not display destroy link to normal members' do
    community = fast_create(Community)
    admin = fast_create(Person)
    community.add_member(admin)

    person = Person['testuser']
    community.add_member(person)

    login_as('testuser')
    get :index, :profile => 'testuser'

    assert_template 'index'
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{community.identifier}/profile_editor/destroy_profile" }
  end

  should 'use the current environment for the template of user' do
    template = Community.create!(:identifier => 'test_template', :name => 'test@bli.com', :is_template => true)
    template.boxes.destroy_all
    template.boxes << Box.new
    template.boxes[0].blocks << Block.new
    template.save!

    env = fast_create(Environment, :name => 'test_env')
    env.settings[:community_template_id] = template.id
    env.save!

    profile.environment = env
    profile.save!
    @controller.stubs(:environment).returns(env)

    post :new_community, :profile => profile.identifier, :community => { :name => 'test community', :description => 'a test community'}

    assert_equal 1, assigns(:community).boxes.size
    assert_equal 1, assigns(:community).boxes[0].blocks.size
  end

  should 'display only templates of the current environment' do
    env2 = fast_create(Environment)

    template1 = fast_create(Community, :name => 'template1', :environment_id => Environment.default.id, :is_template => true)
    template2 = fast_create(Community, :name => 'template2', :environment_id => Environment.default.id, :is_template => true)
    template3 = fast_create(Community, :name => 'template3', :environment_id => env2.id, :is_template => true)

    get :new_community, :profile => profile.identifier

    assert_select '#template-options' do |elements|
      assert_match /template1/, elements[0].to_s
      assert_match /template2/, elements[0].to_s
      assert_no_match /template3/, elements[0].to_s
    end
  end

  should 'display only required fields when register new community' do
    env = Environment.default
    env.custom_community_fields = {
      'contact_email' => {'active' => 'true', 'required' => 'true'},
      'contact_phone' => {'active' => 'true', 'required' => 'false'}
    }
    env.save!

    get :new_community, :profile => profile.identifier

    assert_tag :tag => 'input', :attributes => { :name => 'community[contact_email]' }
    assert_no_tag :tag => 'input', :attributes => { :name => 'community[contact_phone]' }
  end

  should 'display all required fields when register new community' do
    env = Environment.default
    env.custom_community_fields = {
      'contact_email' => {'active' => 'true', 'required' => 'true'},
      'contact_phone' => {'active' => 'true', 'required' => 'true'}
    }
    env.save!

    get :new_community, :profile => profile.identifier

    env.required_community_fields.each do |field|
      assert_tag :tag => 'input', :attributes => { :name => "community[#{field}]" }
    end
  end

  should 'set environment when render new community form' do
    get :new_community, :profile => profile.identifier

    assert_not_nil assigns(:community).environment
   end

  should 'set environment' do
    @controller.stubs(:environment).returns(Environment.default).at_least_once
    post :new_community, :profile => profile.identifier, :community => {:name => 'test community'}

    assert_not_nil assigns(:community).environment
  end

  should 'not show description if isnt enabled when register new community' do
    env = Environment.default
    env.custom_community_fields = { :description => {:active => 'false', :required => 'false'} }
    env.save!

    get :new_community, :profile => profile.identifier

    assert_no_tag :tag => 'textarea', :attributes => {:name => 'community[description]'}
  end

  should 'include hidden fields supplied by plugins on new community' do
    class Plugin1 < Noosfero::Plugin
      def new_community_hidden_fields
        {'plugin1' => 'Plugin 1'}
      end
    end

    class Plugin2 < Noosfero::Plugin
      def new_community_hidden_fields
        {'plugin2' => 'Plugin 2'}
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    environment = Environment.default
    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)

    get :new_community, :profile => profile.identifier

    assert_tag :tag => 'input', :attributes => {:id => 'community_plugin1', :type => 'hidden', :value => 'Plugin 1'}
    assert_tag :tag => 'input', :attributes => {:id => 'community_plugin2', :type => 'hidden', :value => 'Plugin 2'}
  end

  should 'redirect to back_to parameter when community needs admin approval' do
    back_to = '/'
    environment = Environment.default
    environment.enable('admin_must_approve_new_communities')
    post :new_community, :profile => profile.identifier, :community => { :name => 'My shiny new community', :description => 'This is a community devoted to anything interesting we find in the internet '}, :back_to => back_to
    assert_response :redirect
    assert_redirected_to back_to
  end

  should 'cancel button redirect to back_to parameter' do
    back_to = '/'
    get :new_community, :profile => profile.identifier, :back_to => back_to
    assert_tag :tag => 'a', :attributes => { :class => 'button icon-cancel with-text', :href => back_to }
  end

  should 'only display control panel link to members with permission' do
    c1 = fast_create(Community, :name => 'My own community')
    c2 = fast_create(Community, :name => 'Not my community')

    owner = fast_create(Person)
    c2.add_admin(owner)

    person = Person['testuser']
    c1.add_admin(person)
    c2.add_member(person)

    login_as('testuser')
    get :index, :profile => 'testuser'

    assert_template 'index'
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{c2.identifier}" }
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{c1.identifier}" }
  end

  should 'filter memberships by role' do
    c1 = fast_create(Community, :name => 'First community')
    c2 = fast_create(Community, :name => 'Second community')

    role = Role.create!(:name => 'special_role', :permissions => ['edit_profile'], :environment => c2.environment)

    person = Person['testuser']
    c1.add_member(person)
    c2.add_member(person)

    person.add_role(role, c2)

    login_as('testuser')
    get :index, :profile => 'testuser'

    assert_includes assigns(:memberships), c1
    assert_includes assigns(:memberships), c2

    get :index, :profile => 'testuser', :filter_type => role.id

    assert_not_includes assigns(:memberships), c1
    assert_includes assigns(:memberships), c2
  end

  should 'only show roles the user has' do
    c1 = fast_create(Community, :name => 'First community')

    role1 = Role.create!(:name => 'normal_role', :permissions => ['edit_profile'], :environment => c1.environment)
    role2 = Role.create!(:name => 'special_role', :permissions => ['edit_profile'], :environment => c1.environment)

    person = Person['testuser']
    c1.add_member(person)
    person.add_role(role1, c1)

    login_as('testuser')
    get :index, :profile => 'testuser'

    assert_includes assigns(:roles), role1
    assert_not_includes assigns(:roles), role2
  end

  should 'only show roles related to profiles' do
    c1 = fast_create(Community, :name => 'First community')
    role1 = Role.create!(:name => 'profile_role', :permissions => ['edit_profile'], :environment => c1.environment)
    role2 = Role.create!(:name => 'environment_role', :permissions => ['edit_profile'], :environment => c1.environment)

    person = Person['testuser']
    c1.add_member(person)
    person.add_role(role2, c1.environment)
    person.add_role(role1, c1)

    login_as('testuser')
    get :index, :profile => 'testuser'

    assert_includes assigns(:roles), role1
    assert_not_includes assigns(:roles), role2
  end

  should 'display list suggestions button' do
    community = fast_create(Community)
    profile.profile_suggestions.create(:suggestion => community)
    get :index, :profile => 'testuser'
    assert_tag :tag => 'a', :content => 'See some suggestions of communities...', :attributes => { :href => "/myprofile/testuser/memberships/suggest" }
  end

  should 'display communities suggestions' do
    community = fast_create(Community)
    profile.profile_suggestions.create(:suggestion => community)
    get :suggest, :profile => 'testuser'
    assert_tag :tag => 'a', :content => "+ #{community.name}", :attributes => { :href => "/profile/#{community.identifier}/join" }
  end

  should 'display button to join on community suggestion' do
    community = fast_create(Community)
    profile.profile_suggestions.create(:suggestion => community)
    get :suggest, :profile => 'testuser'
    assert_tag :tag => 'a', :attributes => { :href => "/profile/#{community.identifier}/join" }
  end

  should 'display button to remove community suggestion' do
    community = fast_create(Community)
    profile.profile_suggestions.create(:suggestion => community)
    get :suggest, :profile => 'testuser'
    assert_tag :tag => 'a', :attributes => { :href => /\/myprofile\/testuser\/memberships\/remove_suggestion\/#{community.identifier}/ }
  end

  should 'remove suggestion of community' do
    community = fast_create(Community)
    suggestion = profile.profile_suggestions.create(:suggestion => community)
    post :remove_suggestion, :profile => 'testuser', :id => community.identifier

    assert_response :success
    assert_equal false, ProfileSuggestion.find(suggestion.id).enabled
  end

end
