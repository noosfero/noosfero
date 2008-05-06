require File.dirname(__FILE__) + '/../test_helper'
require 'memberships_controller'


# Re-raise errors caught by the controller.
class MembershipsController; def rescue_action(e) raise e end; end

class MembershipsControllerTest < Test::Unit::TestCase
  
  include ApplicationHelper

  def setup
    @controller = MembershipsController.new
    @request    = ActionController::TestRequest.new
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

  should 'present confirmation before joining a profile' do
    community = Community.create!(:name => 'my test community')
    get :join, :profile => profile.identifier, :id => community.id

    assert_response :success
    assert_template 'join'
  end

  should 'actually join profile' do
    community = Community.create!(:name => 'my test community')
    post :join, :profile => profile.identifier, :id => community.id, :confirmation => '1'

    assert_response :redirect
    assert_redirected_to community.url

    profile.reload
    assert profile.memberships.include?(community), 'profile should be actually added to the community'
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
    assert_tag :tag => 'td', :content => /Members: 1/
  end

  should 'show created at on list' do
    community = Community.create!(:name => 'my test community')
    community.add_member(profile)
    get :index, :profile => profile.identifier
    assert_tag :tag => 'td', :content => /Created at: #{show_date(community.created_at)}/
  end

  should 'show description on list' do
    community = Community.create!(:name => 'my test community', :description => 'description test')
    community.add_member(profile)
    get :index, :profile => profile.identifier
    assert_tag :tag => 'td', :content => /Description: description test/
  end

  should 'not show description to enterprises on list' do
    enterprise = Enterprise.create!(:identifier => 'enterprise-test', :name => 'my test enterprise')
    enterprise.add_member(profile)
    get :index, :profile => profile.identifier
    assert_no_tag :tag => 'td', :content => /Description:/
  end

  should 'show link to leave from community' do
    community = Community.create!(:name => 'my test community', :description => 'description test')
    community.add_member(profile)
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/memberships/leave/#{community.id}" }, :content => 'Leave'
  end

  should 'present confirmation before leaving a profile' do
    community = Community.create!(:name => 'my test community')
    get :leave, :profile => profile.identifier, :id => community.id

    assert_response :success
    assert_template 'leave'
  end

  should 'actually leave profile' do
    community = Community.create!(:name => 'my test community')
    post :leave, :profile => profile.identifier, :id => community.id, :confirmation => '1'

    assert_response :redirect
    assert_redirected_to :action => 'index'

    profile.reload
    assert !profile.memberships.include?(community)
  end

end
