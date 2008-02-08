require File.dirname(__FILE__) + '/../test_helper'
require 'manage_communities_controller'

# Re-raise errors caught by the controller.
class ManageCommunitiesController; def rescue_action(e) raise e end; end

class ManageCommunitiesControllerTest < Test::Unit::TestCase

  def setup
    @controller = ManageCommunitiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('mytestuser').person
  end
  attr_reader :profile

  should 'present new community form' do
    get :new, :profile => profile.identifier
    assert_response :success
    assert_template 'new'
  end

  should 'be able to create a new community' do
    assert_difference Community, :count do
      post :new, :profile => profile.identifier, :community => { :name => 'My shiny new community', :description => 'This is a community devoted to anything interesting we find in the internet '}
      assert_response :redirect
      assert_redirected_to :action => 'index'

      assert Community.find_by_identifier('my-shiny-new-community').members.include?(profile), "Creator user should be added as member of the community just created"
    end
  end

  should 'list current communities' do
    get :index, :profile => profile.identifier
    assert_kind_of Array, assigns(:communities)
    assert_response :success
    assert_template 'index'
  end

  should 'link to new community creation' do
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/mytestuser/manage_communities/new' }
  end

end
