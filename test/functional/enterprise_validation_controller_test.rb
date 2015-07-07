require_relative "../test_helper"
require 'enterprise_validation_controller'

class EnterpriseValidationControllerTest < ActionController::TestCase

  all_fixtures

  def setup
    @controller = EnterpriseValidationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    login_as 'ze'
    @org = Organization.create!(:identifier => 'myorg', :name => "My Org")
    give_permission('ze', 'validate_enterprise', @org)
    Profile.expects(:find_by_identifier).with('myorg').returns(@org).at_least_once
  end

  should 'list pending validations on index' do
    empty = []
    @org.expects(:pending_validations).returns(empty)
    get :index, :profile => 'myorg'
    assert_equal empty, assigns(:pending_validations)
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
    validation.stubs(:environment).returns(Environment.default)
    @org.expects(:find_pending_validation).with('kakakaka').returns(validation)

    # FIXME: this is not working, but should. Anyway the assert_response and
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

    assert_equal processed_validations, assigns(:processed_validations)

    assert_response :success
    assert_template 'list_processed'
  end

  should 'be able to display a validation that was already processed' do
    validation = CreateEnterprise.new
    @org.expects(:find_processed_validation).with('kakakaka').returns(validation)
    get :view_processed, :profile => 'myorg', :id => 'kakakaka'
    assert_same validation, assigns(:processed)
  end

  should 'display a form for editing the validation info' do
    info = ValidationInfo.new(:validation_methodology => 'none')
    @org.expects(:validation_info).returns(info)
    get :edit_validation_info, :profile => 'myorg'
    assert_response :success
    assert_equal info, assigns(:info)
  end

  should 'save an alteration of the validation info' do
    info = ValidationInfo.new(:validation_methodology => 'none')
    @org.expects(:validation_info).returns(info)
    post :edit_validation_info, :profile => 'myorg', :info => {:validation_methodology => 'new methodology'}

    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal info, assigns(:info)
  end

  should 'not save an empaty validation mthodology' do
    info = ValidationInfo.new(:validation_methodology => 'none')
    @org.expects(:validation_info).returns(info)
    post :edit_validation_info, :profile => 'myorg', :info => {:validation_methodology => ''}

    assert_response :success
    assert_equal info, assigns(:info)
  end

  should 'filter html from methodology of the validation info' do
    info = ValidationInfo.new(:validation_methodology => 'none')
    @org.expects(:validation_info).returns(info)
    post :edit_validation_info, :profile => 'myorg', :info => {:validation_methodology => 'new <b>methodology</b>'}
    assert_sanitized assigns(:info).validation_methodology
  end

  should 'filter html from restrictions of the validation info' do
    info = ValidationInfo.new(:validation_methodology => 'none')
    @org.expects(:validation_info).returns(info)
    post :edit_validation_info, :profile => 'myorg', :info => {:restrictions => 'new <b>methodology</b>'}
    assert_sanitized assigns(:info).restrictions
  end

end
