require File.dirname(__FILE__) + '/../test_helper'
require 'profile_editor_controller'

# Re-raise errors caught by the controller.
class ProfileEditorController; def rescue_action(e) raise e end; end

class ProfileEditorControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProfileEditorController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as('ze')
  end

  def test_index
    profile = Profile.create(:name => 'a test profile', :identifier => 'test_profile')

    get :index, :profile => profile.identifier
    assert_template :index
    assert_response :success
    assert_not_nil assigns(:profile)

    assert_tag :tag => 'td', :content => 'a test profile'
    assert_tag :tag => 'td', :content => 'my address'
    assert_tag :tag => 'td', :content => 'my contact information'
  end

  def test_edit_person_info
    profile = Person.new
    profile.name = 'a test profile'
    profile.person_info.address = 'my address'
    profile.person_info.contact_information = 'my contact information'
    @controller.instance_variable_set('@profile', profile)

    get :edit, :profile => 'test_profile'
    assert_response :success
    assert_template 'person_info'

  end

  def test_saving_profile_info
    profile = Person.new
    profile.name = 'a test profile'
    profile.person_info.address = 'my address'
    profile.person_info.contact_information = 'my contact information'
    @controller.instance_variable_set('@profile', profile)

    profile.person_info.expects(:update_attributes).with({ 'contact_information' => 'new contact information', 'address' => 'new address' }).returns(true)
    post :edit, :profile => 'test_profile', :info => { 'contact_information' => 'new contact information', 'address' => 'new address' }

    assert_redirected_to :action => 'index'
  end

end
