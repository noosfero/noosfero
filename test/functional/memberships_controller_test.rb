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


end
