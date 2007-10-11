require File.dirname(__FILE__) + '/../test_helper'
require 'region_validators_controller'

# Re-raise errors caught by the controller.
class RegionValidatorsController; def rescue_action(e) raise e end; end

class RegionValidatorsControllerTest < Test::Unit::TestCase
  def setup
    @controller = RegionValidatorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  should 'list regions at index' do
    get :index
    assert_response :success
    assert_template 'index'
    assert_kind_of Array, assigns(:regions)
  end

  should 'view validators for a  specific region' do
    environment = Environment.create!(:name => "my environment")
    region = Region.new(:name => 'my region')
    environment.regions << region
    assert !region.new_record?

    @controller.expects(:environment).returns(environment)

    get :region, :id => region.id

    assert_response :success
    assert_template 'region'
    assert_equal region, assigns(:region)
  end

  should 'search possible validators by name' do
    environment = Environment.create!(:name => "my environment")
    region = Region.new(:name => 'my region')
    environment.regions << region
    assert !region.new_record?
    org = Organization.create!(:name => "My frufru organization", :identifier => 'frufru')

    @controller.expects(:environment).returns(environment)
    Organization.expects(:find_by_contents).with('frufru').returns([org])

    get :search, :id => region.id, :search => 'frufru'

    assert_response :success
    assert_equal [org], assigns(:search)
  end

  should 'be able to add validators to the current region' do
    flunk 'need to write this test'
  end

  should 'be able to remove validators from the current region' do
    flunk 'need to write this test'
  end

end
