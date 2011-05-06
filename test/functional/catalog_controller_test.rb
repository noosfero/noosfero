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

  should 'paginate enterprise products list' do
    1.upto(12).map do
      fast_create(Product, :enterprise_id => @enterprise.id)
    end

    assert_equal 12, @enterprise.products.count
    get :index, :profile => @enterprise.identifier
    assert_equal 10, assigns(:products).count
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
    product = fast_create(Product, :enterprise_id => @enterprise.id)
    plugin1_local_variable = "Plugin1"
    plugin1_content = lambda {"<span id='plugin1'>This is #{plugin1_local_variable} speaking!</span>"}
    plugin2_local_variable = "Plugin2"
    plugin2_content = lambda {"<span id='plugin2'>This is #{plugin2_local_variable} speaking!</span>"}
    contents = [plugin1_content, plugin2_content]

    plugins = mock()
    plugins.stubs(:enabled_plugins).returns([])
    plugins.stubs(:map).with(:body_beginning).returns([])
    plugins.stubs(:map).with(:catalog_item_extras, product).returns(contents)
    Noosfero::Plugin::Manager.stubs(:new).returns(plugins)

    get :index, :profile => @enterprise.identifier

    assert_tag :tag => 'span', :content => 'This is ' + plugin1_local_variable + ' speaking!', :attributes => {:id => 'plugin1'}
    assert_tag :tag => 'span', :content => 'This is ' + plugin2_local_variable + ' speaking!', :attributes => {:id => 'plugin2'}
  end

end
