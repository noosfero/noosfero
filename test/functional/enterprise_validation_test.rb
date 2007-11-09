require File.dirname(__FILE__) + '/../test_helper'
require 'enterprise_validation_controller'

# Re-raise errors caught by the controller.
class EnterpriseValidationController; def rescue_action(e) raise e end; end

class EnterpriseValidationControllerTest < Test::Unit::TestCase

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
    validation = CreateEnterprise.new
    @org.expects(:find_pending_validation).with('kakakaka').returns(validation)
    validation.expects(:approve)
    validation.expects(:code).returns('kakakaka')
    post :approve, :profile => 'myorg', :id => 'kakakaka'
    assert_redirected_to :action => 'view_processed', :id => 'kakakaka'
  end

  should 'be able to reject an enterprise' do
    validation = CreateEnterprise.new
    @org.expects(:find_pending_validation).with('kakakaka').returns(validation)
    validation.expects(:reject)
    validation.expects(:code).returns('kakakaka')
    post :reject, :profile => 'myorg', :id => 'kakakaka', :reject_explanation => 'this is not a solidarity economy enterprise'
    assert_redirected_to :action => 'view_processed', :id => 'kakakaka'
  end

  should 'require the user to fill in the explanation for an rejection' do
    validation = CreateEnterprise.new
    @org.expects(:find_pending_validation).with('kakakaka').returns(validation)

    # this is not working, but should. Anyway the assert_response and
    # assert_template below in some test some things we need. But the
    # expectation below must be put to work.
    #
    #validation.expects(:reject).raises(ActiveRecord::RecordInvalid)

    post :reject, :profile => 'myorg', :id => 'kakakaka'
    assert_response :success
    assert_template 'details'
  end

  should 'list validations already processed' do
    processed_validations = [CreateEnterprise.new]
    @org.expects(:processed_validations).returns(processed_validations)
    
    get :list_processed, :profile => 'myorg'

    assert_same processed_validations, assigns(:processed_validations)

    assert_response :success
    assert_template 'list_processed'
  end
  
  should 'be able to display a validation that was already processed' do
    validation = CreateEnterprise.new
    @org.expects(:find_processed_validation).with('kakakaka').returns(validation)
    get :view_processed, :profile => 'myorg', :id => 'kakakaka'
    assert_same validation, assigns(:processed)
  end

end
