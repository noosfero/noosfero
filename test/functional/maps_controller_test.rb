# encoding: UTF-8
require_relative "../test_helper"
require 'maps_controller'

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

  should 'save profile national_region_code' do

    national_region_code = '355030'
    city = 'Santo Afonso'
    state = 'Mato Grosso'

    fast_create(NationalRegion, :name => 'Brasil',
      :national_region_code => 'BR',
      :national_region_type_id => NationalRegionType::COUNTRY)

    parent_region = fast_create(NationalRegion, :name => state,
                                :national_region_code => '35',
                                :national_region_type_id => NationalRegionType::STATE)

    fast_create(NationalRegion, :name =>  city,
                                :national_region_code => national_region_code,
                                :national_region_type_id => NationalRegionType::CITY,
                                :parent_national_region_code => parent_region.national_region_code)

    post :edit_location, :profile => profile.identifier, :profile_data => {
      :address => 'new address',
      :country => 'BR',
      :city => city,
      :state => state
    }

    assert_equal national_region_code, Profile['test_profile'].national_region_code
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

  should 'autocomplete search_city' do

    city = 'Santo Afonso'
    state = 'Mato Grosso'

    parent_region = fast_create(NationalRegion, :name => state,
                                :national_region_code => '35',
                                :national_region_type_id => NationalRegionType::STATE)

    fast_create(NationalRegion, :name =>  city,
                                :national_region_code => '355030',
                                :national_region_type_id => NationalRegionType::CITY,
                                :parent_national_region_code => parent_region.national_region_code)

    get :search_city, :term => "San", :profile => profile.identifier

    json_response = ActiveSupport::JSON.decode(@response.body)

    label =  json_response[0]['label']
    category =  json_response[0]['category']

    assert_equal city, label
    assert_equal state, category
  end

  should 'autocomplete search_state' do

    state = 'Mato Grosso do Sul'


    fast_create(NationalRegion, :name => state,
                                :national_region_code => '36',
                                :national_region_type_id => NationalRegionType::STATE)


    get :search_state, :term => "Mat", :profile => profile.identifier

    json_response = ActiveSupport::JSON.decode(@response.body)

    label =  json_response[0]['label']

    assert_equal state, label
  end
end
