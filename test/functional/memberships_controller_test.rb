require File.dirname(__FILE__) + '/../test_helper'
require 'memberships_controller'

# Re-raise errors caught by the controller.
class MembershipsController; def rescue_action(e) raise e end; end

class MembershipsControllerTest < Test::Unit::TestCase
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

end
