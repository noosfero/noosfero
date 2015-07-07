require_relative "../test_helper"
require 'region_validators_controller'

class RegionValidatorsControllerTest < ActionController::TestCase
  all_fixtures
  def setup
    @controller = RegionValidatorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as('ze')
  end

  # Replace this with your real tests.
  should 'list regions at index' do
    get :index
    assert_response :success
    assert_template 'index'
    assert assigns(:regions)
  end

  should 'view validators for a  specific region' do
    environment = fast_create(Environment, :name => "my environment")
    give_permission('ze', 'manage_environment_validators', environment)
    region = Region.new(:name => 'my region')
    environment.regions << region
    assert !region.new_record?

    @controller.expects(:environment).returns(environment).at_least_once

    get :region, :id => region.id

    assert_response :success
    assert_template 'region'
    assert_equal region, assigns(:region)
  end

  should 'search possible validators by name' do
    environment = fast_create(Environment, :name => "my environment")
    give_permission('ze', 'manage_environment_validators', environment)
    region = Region.new(:name => 'my region')
    environment.regions << region
    assert !region.new_record?
    org = create(Organization, :name => "My frufru organization", :identifier => 'frufru', :environment_id => environment.id)

    @controller.expects(:environment).returns(environment).at_least_once

    get :search, :id => region.id, :search => 'frufru'

    assert_response :success
    assert_equal [org], assigns(:search)
  end

  should 'be able to add validators to the current region' do
    environment = fast_create(Environment, :name => "my environment")
    give_permission('ze', 'manage_environment_validators', environment)
    region = Region.new(:name => 'my region')
    environment.regions << region
    assert !region.new_record?
    org = create(Organization, :name => "My frufru organization", :identifier => 'frufru', :environment_id => environment.id)

    @controller.expects(:environment).returns(environment).at_least_once

    post :add, :id => region.id, :validator_id => org.id
    assert_response :redirect
    assert_redirected_to :action => 'region', :id => region.id

    assert Region.find(region.id).validators.include?(org)
  end

  should 'be able to remove validators from the current region' do
    environment = fast_create(Environment, :name => "my environment")
    give_permission('ze', 'manage_environment_validators', environment)
    region = Region.new(:name => 'my region')
    environment.regions << region
    assert !region.new_record?
    org = create(Organization, :name => "My frufru organization", :identifier => 'frufru', :environment_id => environment.id)
    region.validators << org

    @controller.expects(:environment).returns(environment).at_least_once

    post :remove, :id => region.id, :validator_id => org.id
    assert_response :redirect
    assert_redirected_to :action => 'region', :id => region.id

    assert !Region.find(region.id).validators.include?(org)
  end

end
