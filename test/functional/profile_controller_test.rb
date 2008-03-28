require File.dirname(__FILE__) + '/../test_helper'
require 'profile_controller'

# Re-raise errors caught by the controller.
class ProfileController; def rescue_action(e) raise e end; end

class ProfileControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testuser').person
  end

  noosfero_test :profile => 'testuser'

  should 'list friends' do
    get :friends

    assert_response :success
    assert_template 'friends'
    assert_kind_of Array, assigns(:friends)
  end

  should 'list communities' do
    get :communities

    assert_response :success
    assert_template 'communities'
    assert_kind_of Array, assigns(:communities)
  end

  should 'list enterprises' do
    get :enterprises

    assert_response :success
    assert_template 'enterprises'
    assert_kind_of Array, assigns(:enterprises)
  end

  should 'list members (for organizations)' do
    get :members

    assert_response :success
    assert_template 'members'
    assert_kind_of Array, assigns(:members)
  end

  should 'show Join This Community button for non-member users' do
    login_as(@profile.identifier)
    community = Community.create!(:name => 'my test community')
    get :index, :profile => community.identifier
    assert_tag :tag => 'a', :content => 'Join this community'
  end

  should 'not show Join This Community button for member users' do
    login_as(@profile.identifier)
    community = Community.create!(:name => 'my test community')
    community.add_member(@profile)
    get :index, :profile => community.identifier
    assert_no_tag :tag => 'a', :content => 'Join this community'
  end

  should 'not show Join This Community button for non-registered users' do
    community = Community.create!(:name => 'my test community')
    get :index, :profile => community.identifier
    assert_no_tag :tag => 'a', :content => 'Join this community'
  end

end
