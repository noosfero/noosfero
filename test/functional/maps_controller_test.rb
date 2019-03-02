require_relative '../test_helper'

class MapsControllerTest < ActionController::TestCase

  def setup
    @controller = MapsController.new

    @profile = create_user('test_profile').person
    @env = Environment.default
    login_as(@profile.identifier)
  end

  attr_reader :profile, :env

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

  should 'go back when update address fail' do
    Profile.any_instance.stubs(:save!).returns(false)
    post :edit_location, :profile => profile.identifier, :profile_data => { 'address' => 'new address' }
    assert_nil profile.address
    assert_template 'edit_location'
  end

  should 'show page to edit location' do
    get :edit_location, :profile => profile.identifier
    assert_response :success
    assert_template 'edit_location'
  end

  should 'display only region categories for selection' do
    fast_create(Region, name: 'Region')
    fast_create(State, name: 'City', environment_id: env.id)
    fast_create(City, name: 'State', environment_id: env.id)
    fast_create(Category, name: 'Not a Region')

    get :edit_location, profile: profile.identifier
    assert_tag :tag => 'a', :attributes => { :class => 'select-subcategory-link' }, :content => 'Region'
    assert_tag :tag => 'a', :attributes => { :class => 'select-subcategory-link' }, :content => 'City'
    assert_tag :tag => 'a', :attributes => { :class => 'select-subcategory-link' }, :content => 'State'
    !assert_tag :tag => 'a', :attributes => { :class => 'select-subcategory-link' }, :content => 'Not a Region'
  end

  should 'display only regions in the selected categories list' do
    region = fast_create(Region, name: 'Region')
    category = fast_create(Category, name: 'Not a Region')
    profile.update_attributes(category_ids: [region.id, category.id])

    get :edit_location, profile: profile.identifier
    assert_tag :tag => 'div', :content => region.name,
                :ancestor => { :tag => 'div', :attributes => { :id => 'category-ajax-selector'}}
    !assert_tag :tag => 'div', :content => category.name,
                :ancestor => { :tag => 'div', :attributes => { :id => 'category-ajax-selector'}}
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

  should 'display location bar if any address field is active' do
    Environment.any_instance.stubs(:custom_person_fields).returns({ 'location' => { 'active' => 'true' },
                                                                    'city' => { 'active' => 'true' } })
    get :edit_location, :profile => profile.identifier
    assert_tag 'div', attributes: { class: /location-bar/ }
  end

# FIXME See a way to remove assert_no_tag
#  should 'not display location bar no address fields are active' do
#    Environment.any_instance.stubs(:custom_person_fields).returns({ 'location' => { 'active' => 'true' } })
#    get :edit_location, :profile => profile.identifier
#    assert_no_tag 'div', attributes: { class: /location-bar/ }
#  end

  should 'accept blank address with lat and lng' do
    Environment.any_instance.stubs(:custom_person_fields).returns({ 'location' => { 'active' => 'true' } })
    post :edit_location, profile: profile.identifier, profile_data: { state: '', city: '', lat: 30, lng: 15 }

    profile.reload
    assert_equal 30, profile.lat
    assert_equal 15, profile.lng
  end
end
