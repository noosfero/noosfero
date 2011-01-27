require File.dirname(__FILE__) + '/../test_helper'
require 'memberships_controller'


# Re-raise errors caught by the controller.
class MembershipsController; def rescue_action(e) raise e end; end

class MembershipsControllerTest < Test::Unit::TestCase
  
  include ApplicationHelper

  def setup
    @controller = MembershipsController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
    @response   = ActionController::TestResponse.new

    @profile = create_user('testuser').person
    login_as('testuser')
  end
  attr_reader :profile

  def test_local_files_reference
    assert_local_files_reference :get, :index, :profile => profile.identifier
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end

  should 'list current memberships' do
    get :index, :profile => profile.identifier

    assert_kind_of Array, assigns(:memberships)
  end

  should 'present new community form' do
    get :new_community, :profile => profile.identifier
    assert_response :success
    assert_template 'new_community'
  end

  should 'be able to create a new community' do
    assert_difference Community, :count do
      post :new_community, :profile => profile.identifier, :community => { :name => 'My shiny new community', :description => 'This is a community devoted to anything interesting we find in the internet '}
      assert_response :redirect
      assert_redirected_to :action => 'index'

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

  should 'show created at on list' do
    community = Community.create!(:name => 'my test community')
    community.add_member(profile)
    get :index, :profile => profile.identifier
    assert_tag :tag => 'li', :content => /Created at: #{show_date(community.created_at)}/
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
    assert_tag :tag => 'a', :attributes => { :href => "/profile/#{community.identifier}/leave?reload=true" }, :content => 'Leave'
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
    template = Community.create!(:identifier => 'test_template', :name => 'test@bli.com')
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

end
