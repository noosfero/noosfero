require File.dirname(__FILE__) + '/../test_helper'
require 'catalog_controller'

# Re-raise errors caught by the controller.
class CatalogController; def rescue_action(e) raise e end; end

class CatalogControllerTest < ActionController::TestCase
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
    assert_redirected_to :controller => "profile", :profile => 'testinguser', :action => 'index'
  end

  should 'display for enterprises' do
    get :index, :profile => 'testent'
    assert_response :success
  end
  
  should 'list products of enterprise' do
    get :index, :profile => @enterprise.identifier
    assert_kind_of Array, assigns(:products)
  end

  should 'paginate enterprise products list' do
    1.upto(12).map do
      fast_create(Product, :enterprise_id => @enterprise.id)
    end

    assert_equal 12, @enterprise.products.count
    get :index, :profile => @enterprise.identifier
    assert_equal 9, assigns(:products).count
    assert_tag :a, :attributes => {:class => 'next_page'}
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
    assert_no_tag :tag => 'span', :attributes => { :class => 'product-price with-discount' }, :content => /50.00/
  end

  should 'show product price when listing products if informed' do
    prod = @enterprise.products.create!(:name => 'Product test', :price => 50.00, :product_category => @product_category)
    get :index, :profile => @enterprise.identifier
    assert_tag :tag => 'span', :attributes => { :class => 'product-price with-discount' }, :content => /50.00/
  end

  should 'add an zero width space every 4 caracters of comment urls' do
    url = 'www.an.url.to.be.splited.com'
    prod = @enterprise.products.create!(:name => 'Product test', :price => 50.00, :product_category => @product_category, :description => url)
    get :index, :profile => @enterprise.identifier
    assert_tag :a, :attributes => { :href => "http://" + url}, :content => url.scan(/.{4}/).join('&#x200B;')
  end

  should 'show action moved to manage_products controller' do
    assert_raise ActionController::RoutingError do
      get :show, :id => 1
    end
  end

  should 'include extra content supplied by plugins on catalog item extras' do
    class Plugin1 < Noosfero::Plugin
      def catalog_item_extras(product)
        lambda {"<span id='plugin1'>This is Plugin1 speaking!</span>"}
      end
    end

    class Plugin2 < Noosfero::Plugin
      def catalog_item_extras(product)
        lambda {"<span id='plugin2'>This is Plugin2 speaking!</span>"}
      end
    end

    product = fast_create(Product, :enterprise_id => @enterprise.id)
    environment = Environment.default
    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)

    get :index, :profile => @enterprise.identifier

    assert_tag :tag => 'span', :content => 'This is Plugin1 speaking!', :attributes => {:id => 'plugin1'}
    assert_tag :tag => 'span', :content => 'This is Plugin2 speaking!', :attributes => {:id => 'plugin2'}
  end

end
