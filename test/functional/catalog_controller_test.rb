require_relative "../test_helper"
require 'catalog_controller'

class CatalogControllerTest < ActionController::TestCase
  def setup
    @controller = CatalogController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    Environment.default.enable('products_for_enterprises')
    @enterprise = fast_create(Enterprise, :name => 'My enterprise', :identifier => 'testent')
    @product_category = fast_create(ProductCategory)
  end
  attr_accessor :enterprise

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
    assert assigns(:products)
  end

  should 'paginate enterprise products list' do
    1.upto(12).map do
      fast_create(Product, :profile_id => @enterprise.id)
    end

    assert_equal 12, @enterprise.products.count
    get :index, :profile => @enterprise.identifier
    assert_equal 6, assigns(:products).size
    assert_tag :a, :attributes => {:class => 'next_page'}
  end

  should 'not give access if environment do not let' do
    env = Environment.default
    env.disable('products_for_enterprises')
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

  should 'show action moved to manage_products controller' do
    assert_raise ActionController::UrlGenerationError do
      get :show, :id => 1
    end
  end

  should 'include extra content supplied by plugins on catalog item extras' do
    class Plugin1 < Noosfero::Plugin
      def catalog_item_extras(product)
        proc {"<span id='plugin1'>This is Plugin1 speaking!</span>"}
      end
    end

    class Plugin2 < Noosfero::Plugin
      def catalog_item_extras(product)
        proc {"<span id='plugin2'>This is Plugin2 speaking!</span>"}
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    product = fast_create(Product, :profile_id => @enterprise.id)
    environment = Environment.default
    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)

    get :index, :profile => @enterprise.identifier

    assert_tag :tag => 'span', :content => 'This is Plugin1 speaking!', :attributes => {:id => 'plugin1'}
    assert_tag :tag => 'span', :content => 'This is Plugin2 speaking!', :attributes => {:id => 'plugin2'}
  end

  should 'get categories of the right level' do
    pc1 = create(ProductCategory, :name => "PC1", :environment => @enterprise.environment)
    pc2 = create(ProductCategory, :name => "PC2", :environment => @enterprise.environment, :parent_id => pc1.id)
    pc3 = create(ProductCategory, :name => "PC3", :environment => @enterprise.environment, :parent_id => pc1.id)
    pc4 = create(ProductCategory, :name => "PC4", :environment => @enterprise.environment, :parent_id => pc2.id)
    p1 = fast_create(Product, :product_category_id => pc1.id, :profile_id => @enterprise.id)
    p2 = fast_create(Product, :product_category_id => pc2.id, :profile_id => @enterprise.id)
    p3 = fast_create(Product, :product_category_id => pc3.id, :profile_id => @enterprise.id)
    p4 = fast_create(Product, :product_category_id => pc4.id, :profile_id => @enterprise.id)

    get :index, :profile => @enterprise.identifier, :level => pc1.id

    assert_not_includes assigns(:categories), pc1
    assert_includes assigns(:categories), pc2
    assert_includes assigns(:categories), pc3
    assert_not_includes assigns(:categories), pc4
  end

  should 'filter products based on level selected' do
    pc1 = ProductCategory.create!(:name => "PC1", :environment => @enterprise.environment)
    pc2 = ProductCategory.create!(:name => "PC2", :environment => @enterprise.environment, :parent_id => pc1.id)
    pc3 = ProductCategory.create!(:name => "PC3", :environment => @enterprise.environment, :parent_id => pc1.id)
    pc4 = ProductCategory.create!(:name => "PC4", :environment => @enterprise.environment, :parent_id => pc2.id)
    p1 = fast_create(Product, :product_category_id => pc1.id, :profile_id => @enterprise.id)
    p2 = fast_create(Product, :product_category_id => pc2.id, :profile_id => @enterprise.id)
    p3 = fast_create(Product, :product_category_id => pc3.id, :profile_id => @enterprise.id)
    p4 = fast_create(Product, :product_category_id => pc4.id, :profile_id => @enterprise.id)

    get :index, :profile => @enterprise.identifier, :level => pc2.id

    assert_not_includes assigns(:products), p1
    assert_includes assigns(:products), p2
    assert_not_includes assigns(:products), p3
    assert_includes assigns(:products), p4
  end

  should 'get products ordered by availability, highlighted and then name' do
    p1 = fast_create(Product, :profile_id => @enterprise.id, :name => 'Zebra', :available => true, :highlighted => true)
    p2 = fast_create(Product, :profile_id => @enterprise.id, :name => 'Car', :available => true)
    p3 = fast_create(Product, :profile_id => @enterprise.id, :name => 'Panda', :available => true)
    p4 = fast_create(Product, :profile_id => @enterprise.id, :name => 'Pen', :available => false, :highlighted => true)
    p5 = fast_create(Product, :profile_id => @enterprise.id, :name => 'Ball', :available => false)
    p6 = fast_create(Product, :profile_id => @enterprise.id, :name => 'Medal', :available => false)

    get :index, :profile => @enterprise.identifier

    assert_equal [p1,p2,p3,p4,p5,p6], assigns(:products)
  end

  should 'add highlighted CSS class around a highlighted product' do
    prod = @enterprise.products.create!(:name => 'Highlighted Product', :product_category => @product_category, :highlighted => true)
    get :index, :profile => @enterprise.identifier
    assert_tag :tag => 'li', :attributes => { :class => 'product highlighted' }, :content => /Highlighted Product/
  end

  should 'do not add highlighted CSS class around an ordinary product' do
    prod = @enterprise.products.create!(:name => 'Ordinary Product', :product_category => @product_category, :highlighted => false)
    get :index, :profile => @enterprise.identifier
    assert_no_tag :tag => 'li', :attributes => { :class => 'product highlighted' }, :content => /Ordinary Product/
  end

  should 'display star image in highlighted product' do
    prod = @enterprise.products.create!(:name => 'The Eyes Are The Light', :product_category => @product_category, :highlighted => true)
    get :index, :profile => @enterprise.identifier
    assert_tag :tag => 'img', :attributes => { :class => 'star', :src => /star.png/ }
  end

  should 'display categories on breadcrumb' do
    pc1 = create(ProductCategory, :name => "PC1", :environment => @enterprise.environment)
    pc2 = create(ProductCategory, :name => "PC2", :environment => @enterprise.environment, :parent_id => pc1.id)
    pc3 = create(ProductCategory, :name => "PC3", :environment => @enterprise.environment, :parent_id => pc1.id)
    pc4 = create(ProductCategory, :name => "PC4", :environment => @enterprise.environment, :parent_id => pc2.id)
    p1 = fast_create(Product, :product_category_id => pc1.id, :profile_id => @enterprise.id)
    p2 = fast_create(Product, :product_category_id => pc2.id, :profile_id => @enterprise.id)
    p3 = fast_create(Product, :product_category_id => pc3.id, :profile_id => @enterprise.id)
    p4 = fast_create(Product, :product_category_id => pc4.id, :profile_id => @enterprise.id)

    get :index, :profile => @enterprise.identifier, :level => pc4.id

    assert_tag :tag => 'div', :attributes => {:id => 'breadcrumb'}, :descendant => {:tag => 'a', :attributes => {:href => /level=#{pc1.id}/}}
    assert_tag :tag => 'div', :attributes => {:id => 'breadcrumb'}, :descendant => {:tag => 'a', :attributes => {:href => /level=#{pc2.id}/}}
    assert_tag :tag => 'div', :attributes => {:id => 'breadcrumb'}, :descendant => {:tag => 'strong', :content => pc4.name}
    assert_no_tag :tag => 'div', :attributes => {:id => 'breadcrumb'}, :descendant => {:tag => 'a', :attributes => {:href => /level=#{pc3.id}/}}
  end

  should 'add product status on the class css' do
    category = create(ProductCategory, :name => "Cateogry", :environment => @enterprise.environment)
    p1 = fast_create(Product, :product_category_id => category.id, :profile_id => @enterprise.id, :highlighted => true)
    p2 = fast_create(Product, :product_category_id => category.id, :profile_id => @enterprise.id, :available => false)

    get :index, :profile => @enterprise.identifier

    assert_tag :tag => 'li', :attributes => {:id => "product-#{p1.id}", :class => /highlighted/}
    assert_tag :tag => 'li', :attributes => {:id => "product-#{p2.id}", :class => /not-available/}
  end

  should 'sort categories by name' do
    environment = @enterprise.environment
    environment.categories.destroy_all
    pc1 = create(ProductCategory, :name => "Drinks", :environment => environment)
    pc2 = create(ProductCategory, :name => "Bananas", :environment => environment)
    pc3 = create(ProductCategory, :name => "Sodas", :environment => environment)
    pc4 = create(ProductCategory, :name => "Pies", :environment => environment)
    p1 = fast_create(Product, :product_category_id => pc1.id, :profile_id => @enterprise.id)
    p2 = fast_create(Product, :product_category_id => pc2.id, :profile_id => @enterprise.id)
    p3 = fast_create(Product, :product_category_id => pc3.id, :profile_id => @enterprise.id)
    p4 = fast_create(Product, :product_category_id => pc4.id, :profile_id => @enterprise.id)

    get :index, :profile => @enterprise.identifier

    assert_equal [pc2, pc1, pc4, pc3], assigns(:categories)
  end

  should 'use price_detail name instead of production_cost name straight' do
    p1 = fast_create(Product, :product_category_id => @product_category.id, :profile_id => @enterprise.id)
    p2 = fast_create(Product, :product_category_id => @product_category.id, :profile_id => @enterprise.id)
    Product.any_instance.stubs(:price_described?).returns(true)
    production_cost = fast_create(ProductionCost)
    pd1 = create(PriceDetail, :product => p1, :production_cost_id => production_cost.id)
    pd2 = create(PriceDetail, :product => p2)

    get :index, :profile => @enterprise.identifier

    assert_tag :tag => 'div', :attributes => {:class => 'search-product-input-name'}, :content => production_cost.name
    assert_tag :tag => 'div', :attributes => {:class => 'search-product-input-name'}, :content => 'Other costs'
  end

end
