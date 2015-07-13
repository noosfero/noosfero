require 'test_helper'
require 'profile_editor_controller'

# Re-raise errors caught by the controller.
class ProfileEditorController; def rescue_action(e) raise e end; end

class ProfileEditorControllerTest < ActionController::TestCase

  def setup
    @controller = ProfileEditorController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @profile = create_user('default_user').person
    login_as(@profile.identifier)
    Environment.default.enable_plugin(GoogleAnalyticsPlugin.name)
  end

  attr_accessor :profile

  should 'add extra fields to profile editor info and settings' do
    get :edit, :profile => profile.identifier
    assert_tag_in_string @response.body, :tag => 'label', :content => /Google Analytics/,  :attributes => { :for => 'profile_data_google_analytics_profile_id' }
    assert_tag_in_string @response.body, :tag => 'input', :attributes => { :id => 'profile_data_google_analytics_profile_id' }
  end

  should 'save code filled in on field' do
    post :edit, :profile => profile.identifier, :profile_data => {:google_analytics_profile_id => 12345678}
    assert_equal '12345678', Person.find(profile.id).google_analytics_profile_id
  end

end
