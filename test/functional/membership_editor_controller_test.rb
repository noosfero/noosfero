require File.dirname(__FILE__) + '/../test_helper'
require 'membership_editor_controller'

# Re-raise errors caught by the controller.
class MembershipEditorController; def rescue_action(e) raise e end; end

class MembershipEditorControllerTest < Test::Unit::TestCase
  def setup
    @controller = MembershipEditorController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as('ze')
  end
  all_fixtures

  should 'list the memberships of the person' do
    get :index, :profile => 'ze'
    assert assigns(:memberships)
    assert_kind_of Array, assigns(:memberships)
  end

  should 'prompt for new enterprise data' do
    get :new_enterprise, :profile => 'ze'
    assert assigns(:virtual_communities)
    assert_kind_of Array, assigns(:virtual_communities)
    assert assigns(:validation_entities)
    assert_kind_of Array, assigns(:validation_entities)
  end

  should 'create a new enterprise' do
    post :create_enterprise, :profile => 'ze', :enterprise => {:name => 'New Ent', :identifier => 'new_net'}
    assert assigns(:enterprise)
    assert_kind_of Enterprise, assigns(:enterprise)
  end
end
