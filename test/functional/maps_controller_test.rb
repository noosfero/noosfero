require File.dirname(__FILE__) + '/../test_helper'
require 'maps_controller'

# Re-raise errors caught by the controller.
class MapsController; def rescue_action(e) raise e end; end

class MapsControllerTest < ActionController::TestCase

  def setup
    @controller = MapsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('test_profile').person
    login_as(@profile.identifier)
  end

  attr_reader :profile

  should 'save profile address' do
    post :edit_location, :profile => profile.identifier, :profile_data => { 'address' => 'new address' }
    assert_equal 'new address', Profile['test_profile'].address
  end

  should 'back when update address fail' do
    Profile.any_instance.stubs(:update_attributes!).returns(false)
    post :edit_location, :profile => profile.identifier, :profile_data => { 'address' => 'new address' }
    assert_nil profile.address
    assert_template 'edit_location'
  end

  should 'show page to edit location' do
    get :edit_location, :profile => profile.identifier
    assert_response :success
    assert_template 'edit_location'
  end

  should 'dispĺay form for address with profile address' do
    env = Environment.default
    env.custom_person_fields = { 'city' => { 'active' => 'true' } }
    env.save!


    get :edit_location, :profile => profile.identifier
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[city]' }
  end

  should 'add script tag for google maps' do
    domain = fast_create(Domain, :name => 'domain-with-key', :google_maps_key => 'DOMAIN_KEY')
    profile.preferred_domain = domain
    profile.save!

    get 'edit_location', :profile => profile.identifier

    assert_tag :tag => 'script', :attributes => { :src => 'http://maps.google.com/maps?file=api&amp;v=2&amp;key=DOMAIN_KEY'}
  end
end
