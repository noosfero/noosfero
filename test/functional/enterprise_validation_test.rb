require File.dirname(__FILE__) + '/../test_helper'
require 'enterprise_validation_controller'

# Re-raise errors caught by the controller.
class EnterpriseValidationController; def rescue_action(e) raise e end; end

class EnterpriseValidationControllerTest < Test::Unit::TestCase

#  all_fixtures:users
all_fixtures
  def setup
    @controller = EnterpriseValidationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as 'ze'

    @org = Organization.create!(:identifier => 'myorg', :name => "My Org")
    Profile.expects(:find_by_identifier).with('myorg').returns(@org).at_least_once
  end

  should 'list pending validations on index' do
    empty = []
    @org.expects(:pending_validations).returns(empty)
    get :index, :profile => 'myorg'
    assert_same empty, assigns(:pending_validations)
    assert_template 'index'
  end

  should 'display details and prompt for needed data when approving or rejecting enterprise' do
    validating = CreateEnterprise.new
    @org.expects(:find_pending_validation).with('kakakaka').returns(validating)

    get :details, :profile => 'myorg', :id => 'kakakaka'
    assert_same validating, assigns(:pending)
  end

  should 'refuse to validate unexisting request' do
    @org.expects(:find_pending_validation).with('kakakaka').returns(nil)
    get :details , :profile => 'myorg', :id => 'kakakaka'
    assert_response 404
  end

  should 'be able to actually validate enterprise on request' do
    flunk 'not yet'
  end

  should 'be able to reject an enterprise' do
    flunk 'not yet'
  end

  should 'require the user to fill in the justification for an rejection' do
    flunk 'not yet'
  end

end
