require File.dirname(__FILE__) + '/../test_helper'
require 'catalog_controller'

# Re-raise errors caught by the controller.
class CatalogController; def rescue_action(e) raise e end; end

class CatalogControllerTest < Test::Unit::TestCase
  def setup
    @controller = CatalogController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @enterprise = Enterprise.create!(:name => 'My enterprise', :identifier => 'testent')
  end

  def test_local_files_reference
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    assert_local_files_reference :get, :index, :profile => ent.identifier
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
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    get :index, :profile => ent.identifier
    assert_kind_of Array, assigns(:products)
  end

  should 'show product of enterprise' do
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    prod = ent.products.create!(:name => 'Product test')
    get :show, :id => prod.id, :profile => ent.identifier
    assert_tag :tag => 'h1', :content => /#{prod.name}/
  end

  should 'link back to index from product show' do
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    prod = ent.products.create!(:name => 'Product test')
    get :show, :id => prod.id, :profile => ent.identifier
    assert_tag({
      :tag => 'div',
      :attributes => {
        :class => /main-block/
      },
      :descendant => {
        :tag => 'a',
        :attributes => {
          :href => '/catalog/test_enterprise1'
        }
      }
    })
    
  end

  should 'not give access if environment do not let' do
    env = Environment.default
    env.enable('disable_products_for_enterprises')
    env.save!
    ent = Enterprise.create!(:name => 'test ent', :identifier => 'test_ent', :environment => env)
    get :index, :profile => ent.identifier

    assert_redirected_to :controller => 'profile', :action => 'index', :profile => ent.identifier
  end

  should 'not show product price when listing products if not informed' do
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    prod = ent.products.create!(:name => 'Product test')
    get :index, :profile => ent.identifier
    assert_no_tag :tag => 'li', :attributes => { :class => 'product_price' }, :content => /Price:/
  end

  should 'show product price when listing products if informed' do
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    prod = ent.products.create!(:name => 'Product test', :price => 50.00)
    get :index, :profile => ent.identifier
    assert_tag :tag => 'li', :attributes => { :class => 'product_price' }, :content => /Price:/
  end

  should 'not show product price when showing product if not informed' do
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    prod = ent.products.create!(:name => 'Product test')
    get :show, :id => prod.id, :profile => ent.identifier

    assert_no_tag :tag => 'p', :attributes => { :class => 'product_price' }, :content => /Price:/
  end

  should 'show product price when showing product if informed' do
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    prod = ent.products.create!(:name => 'Product test', :price => 50.00)
    get :show, :id => prod.id, :profile => ent.identifier

    assert_tag :tag => 'p', :attributes => { :class => 'product_price' }, :content => /Price:/
  end

  should 'not crash on index when product has no product_category and enterprise not enabled' do
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1', :enabled => false)
    prod = ent.products.create!(:name => 'Product test', :price => 50.00, :product_category => nil)
    assert_nothing_raised do
      get :index, :profile => ent.identifier
    end
  end

end
