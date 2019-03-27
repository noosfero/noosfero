require_relative '../test_helper'

class EnterpriseValidationControllerTest < ActionController::TestCase

  all_fixtures

  def setup
    @controller = EnterpriseValidationController.new

    login_as 'ze'
    @user = Profile['ze']
    @org = Organization.create!(identifier: 'myorg', name: "My Org")
    give_permission('ze', 'validate_enterprise', @org)
  end

  should 'list pending validations on index' do
    get :index, profile: 'myorg'
    assert_equal [], assigns(:pending_validations)
    assert_template 'index'
  end

  should 'display details and prompt for needed data when approving or rejecting enterprise' do
    code = 'kakakaka'
    @user.stubs(:is_admin?).returns(false) # admin does not need approvement
    @org.validations.create! code: code, name: 'test', identifier: 'test', requestor: @user, target: @org
    get :details, profile: 'myorg', id: code
    assert_equal @org.find_pending_validation(code), assigns(:pending)
  end

  should 'refuse to validate unexisting request' do
    get :details, profile: 'myorg', id: 'kakakaka'
    assert_response 404
  end

  should 'be able to actually validate enterprise on request' do
    code = 'kakakaka'
    @org.validations.create! code: code, name: 'test2', identifier: 'test2', requestor: @user, target: @org
    post :approve, profile: 'myorg', id: code
    assert 'render_not_found'
  end

  should 'be able to reject an enterprise' do
    code = 'kakakaka'
    @org.validations.create! code: code, name: 'test2', identifier: 'test2', requestor: @user, target: @org
    post :reject, profile: 'myorg', id: code, reject_explanation: 'this is not a solidarity economy enterprise'
    assert 'render_not_found'
  end

  should 'require the user to fill in the explanation for an rejection' do
    code = 'kakakaka'
    @org.validations.create! code: code, name: 'test2', identifier: 'test2', requestor: @user, target: @org

    post :reject, profile: 'myorg', id: code
    assert 'render_not_found'
  end

  should 'list validations already processed' do
    v = @org.validations.create! code: 'kakakaka', name: 'test2', identifier: 'test2', requestor: @user, target: @org

    get :list_processed, profile: 'myorg'

    assert_equal @org.processed_validations, assigns(:processed_validations)

    assert_response :success
    assert_template 'list_processed'
  end

  should 'be able to display a validation that was already processed' do
    code = 'kakakaka'
    v = @org.validations.create! code: code, name: 'test2', identifier: 'test2', requestor: @user, target: @org

    get :view_processed, profile: 'myorg', id: code
    assert_not_same @org.processed_validations.first, assigns(:processed)
  end

  should 'display a form for editing the validation info' do
    info = @org.validation_info = ValidationInfo.create! validation_methodology: 'none', organization: @org
    get :edit_validation_info, profile: 'myorg'
    assert_response :success
    assert_equal info, assigns(:info)
  end

  should 'save an alteration of the validation info' do
    info = @org.validation_info = ValidationInfo.create! validation_methodology: 'none', organization: @org
    post :edit_validation_info, profile: 'myorg', info: {validation_methodology: 'new methodology'}

    assert_response :redirect
    assert_redirected_to action: 'index'
    info.reload
    assert_equal info.reload, assigns(:info)
  end

  should 'not save an empaty validation mthodology' do
    info = @org.validation_info = ValidationInfo.create! validation_methodology: 'none', organization: @org
    post :edit_validation_info, profile: 'myorg', info: {validation_methodology: ''}

    assert_response :success
    assert_equal info, assigns(:info)
  end

  should 'filter html from methodology of the validation info' do
    @org.validation_info = ValidationInfo.create! validation_methodology: 'none', organization: @org
    post :edit_validation_info, profile: 'myorg', info: {validation_methodology: 'new <b>methodology</b>'}
    assert_sanitized assigns(:info).validation_methodology
  end

  should 'filter html from restrictions of the validation info' do
    @org.validation_info = ValidationInfo.create! validation_methodology: 'none', organization: @org
    post :edit_validation_info, profile: 'myorg', info: {restrictions: 'new <b>methodology</b>'}
    assert_sanitized assigns(:info).restrictions
  end

  should 'skip the validation process when the requestor is admin' do
    code = 'kakakaka'
    @org.validations.create! code: code, name: 'nametest', identifier: 'idtest', requestor: @user, target: @org
    get :details, profile: 'myorg', id: code
    assert_equal @org.find_pending_validation(code), assigns(:finished)
  end

  should 'not finish enterprise when requestor is not admin' do
    @user.stubs(:is_admin?).returns(false) # admin does not need approvement
    code = 'kakakaka'
    @org.validations.create! code: code, name: 'nametest1', identifier: 'idtest1', requestor: @user, target: @org
    get :details, profile: 'myorg', id: code
    assert_equal @org.find_pending_validation(code), assigns(:pending)
  end



end
