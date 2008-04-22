require File.dirname(__FILE__) + '/../test_helper'
require 'consumed_products_controller'

# Re-raise errors caught by the controller.
class ConsumedProductsController; def rescue_action(e) raise e end; end

class ConsumedProductsControllerTest < Test::Unit::TestCase

  all_fixtures

  def setup
    @controller = ConsumedProductsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testinguser').person
  end
  attr_reader :profile

  should 'display new form' do
    login_as(profile.identifier)
    get :new, :profile => profile.identifier
    assert_tag :tag => 'h2', :content => 'Add product'
  end

  should 'create product' do
    login_as(profile.identifier)
    product_category = ProductCategory.create!(:name => 'Food', :environment => Environment.default)
    assert_difference Consumption, :count do
      post :new, :profile => profile.identifier, :consumption => { :product_category_id => product_category.id }
    end
  end

  should 'display list of products' do
    login_as(profile.identifier)
    product_category = ProductCategory.create!(:name => 'Food', :environment => Environment.default)
    profile.consumptions.create!(:product_category_id => product_category.id, :aditional_specifications => 'extra info')
    get :index, :profile => profile.identifier
    assert_tag :tag => 'pre', :content => 'extra info'
  end

  should 'filter html from specifications' do
    login_as(profile.identifier)
    product_category = ProductCategory.create!(:name => 'Food', :environment => Environment.default)
    post :new, :profile => profile.identifier,
      :consumption => { :product_category_id => product_category.id, :aditional_specifications => 'extra <b>info</b>' }
    assert_not_equal assigns(:consumption).aditional_specifications, 'extra <b>info</b>'
  end

  should 'destroy product' do
    login_as(profile.identifier)
    product_category = ProductCategory.create!(:name => 'Food', :environment => Environment.default)
    product = profile.consumptions.create!(:product_category_id => product_category.id, :aditional_specifications => 'extra info')
    assert_difference Consumption, :count, -1 do
      post :destroy, :profile => profile.identifier, :id => product.id
    end
  end
  
end
