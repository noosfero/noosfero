require File.dirname(__FILE__) + '/../test_helper'
require 'catalog_controller'

# Re-raise errors caught by the controller.
class CatalogController; def rescue_action(e) raise e end; end

class CatalogControllerTest < Test::Unit::TestCase
  def setup
    @controller = CatalogController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @enterprise = fast_create(Enterprise, :name => 'My enterprise', :identifier => 'testent')
    @product_category = fast_create(ProductCategory)
  end
  attr_accessor :enterprise

  def test_local_files_reference
    assert_local_files_reference :get, :index, :profile => @enterprise.identifier
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end

  should 'not display for non-enterprises' do
    u = create_user('testinguser').person
    get :index, :profile => 'testinguser'
    assert_redirected_to :controller => "profile", :profile => 'testinguser'
  end

  should 'display for enterprises' do
    get :index, :profile => 'testent'
    assert_response :success
  end
  
  should 'list products of enterprise' do
    get :index, :profile => @enterprise.identifier
    assert_kind_of Array, assigns(:products)
  end

  should 'not give access if environment do not let' do
    env = Environment.default
    env.enable('disable_products_for_enterprises')
    env.save!
    ent = fast_create(Enterprise, :name => 'test ent', :identifier => 'test_ent', :environment_id => env.id)
    get :index, :profile => ent.identifier

    assert_redirected_to :controller => 'profile', :action => 'index', :profile => ent.identifier
  end

  should 'not show product price when listing products if not informed' do
    prod = @enterprise.products.create!(:name => 'Product test', :product_category => @product_category)
    get :index, :profile => @enterprise.identifier
    assert_no_tag :tag => 'li', :attributes => { :class => 'product_price' }, :content => /Price:/
  end

  should 'show product price when listing products if informed' do
    prod = @enterprise.products.create!(:name => 'Product test', :price => 50.00, :product_category => @product_category)
    get :index, :profile => @enterprise.identifier
    assert_tag :tag => 'li', :attributes => { :class => 'product_price' }, :content => /Price:/
  end

  should 'link to assets products wiht product category in the link to product category on index' do
    pc = ProductCategory.create!(:name => 'some product', :environment => enterprise.environment)
    prod = enterprise.products.create!(:name => 'Product test', :price => 50.00, :product_category => pc)

    get :index, :profile => enterprise.identifier
    assert_tag :tag => 'a', :attributes => {:href => /assets\/products\?product_category=#{pc.id}/}
  end

end
