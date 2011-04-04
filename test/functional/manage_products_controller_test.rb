require File.dirname(__FILE__) + '/../test_helper'
require 'manage_products_controller'

# Re-raise errors caught by the controller.
class ManageProductsController; def rescue_action(e) raise e end; end

class ManageProductsControllerTest < ActionController::TestCase
  all_fixtures
  def setup
    @controller = ManageProductsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @enterprise = fast_create(Enterprise, :name => 'teste', :identifier => 'test_ent')
    @user = create_user_with_permission('test_user', 'manage_products', @enterprise)
    @environment = @enterprise.environment
    @product_category = fast_create(ProductCategory)
    login_as :test_user
  end

  def test_local_files_reference
    assert_local_files_reference :get, :index, :profile => @enterprise.identifier
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  should "not have permission" do
    u = create_user('user_test')
    login_as :user_test
    get 'index', :profile => @enterprise.identifier
    assert :success
    assert_template 'access_denied.rhtml'
  end

  should "get index" do
    get 'index', :profile => @enterprise.identifier
    assert_response :success
    assert assigns(:products)
  end

  should "get new form" do
    get 'new', :profile => @enterprise.identifier
    assert_response :success
    assert assigns(:product)
    assert_template 'new'
    assert_tag :tag => 'form', :attributes => { :action => /new/ } 
  end

  should "create new product" do
    assert_difference Product, :count do
      post 'new', :profile => @enterprise.identifier, :product => {:name => 'test product'}, :selected_category_id => @product_category.id
      assert assigns(:product)
      assert !assigns(:product).new_record?
    end
  end

  should "not create invalid product" do
    assert_no_difference Product, :count do
      post 'new', :profile => @enterprise.identifier, :product => {:name => 'test product'}
      assert_response :success
      assert assigns(:product)
      assert assigns(:product).new_record?
    end
  end

  should "get edit name form" do
    product = fast_create(Product, :name => 'test product', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    get 'edit', :profile => @enterprise.identifier, :id => product.id, :field => 'name'
    assert_response :success
    assert assigns(:product)
    assert_tag :tag => 'form', :attributes => { :action => /myprofile\/#{@enterprise.identifier}\/manage_products\/edit\/#{product.id}\?field=name/ }
  end

  should "get edit info form" do
    product = fast_create(Product, :name => 'test product', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    get 'edit', :profile => @enterprise.identifier, :id => product.id, :field => 'info'
    assert_response :success
    assert assigns(:product)
    assert_tag :tag => 'form', :attributes => { :action => /myprofile\/#{@enterprise.identifier}\/manage_products\/edit\/#{product.id}\?field=info/ }
  end

  should "get edit image form" do
    product = fast_create(Product, :name => 'test product', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    get 'edit', :profile => @enterprise.identifier, :id => product.id, :field => 'image'
    assert_response :success
    assert assigns(:product)
    assert_tag :tag => 'form', :attributes => { :action => /myprofile\/#{@enterprise.identifier}\/manage_products\/edit\/#{product.id}\?field=image/ }
  end

  should "edit product name" do
    product = fast_create(Product, :name => 'test product', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    post :edit, :profile => @enterprise.identifier, :product => {:name => 'new test product'}, :id => product.id, :field => 'name'
    assert_response :success
    assert assigns(:product)
    assert ! assigns(:product).new_record?
    assert_equal product, Product.find_by_name('new test product')
  end

  should "edit product description" do
    product = fast_create(Product, :name => 'test product', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id, :description => 'My product is very good')
    post :edit, :profile => @enterprise.identifier, :product => {:description => 'A very good product!'}, :id => product.id, :field => 'info'
    assert_response :success
    assert assigns(:product)
    assert ! assigns(:product).new_record?
    assert_equal 'A very good product!', Product.find_by_name('test product').description
  end

  should "edit product image" do
    product = fast_create(Product, :name => 'test product', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    post :edit, :profile => @enterprise.identifier, :product => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }, :id => product.id, :field => 'image'
    assert_response :success
    assert assigns(:product)
    assert ! assigns(:product).new_record?
    assert_equal 'rails.png', Product.find_by_name('test product').image.filename
  end

  should "not edit to invalid parameters" do
    product = fast_create(Product, :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    post 'edit_category', :profile => @enterprise.identifier, :selected_category_id => nil, :id => product.id
    assert_response :success
    assert_template 'shared/_dialog_error_messages'
  end

  should "destroy product" do
    product = fast_create(Product, :name => 'test product', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    assert_difference Product, :count, -1 do
      post 'destroy', :profile => @enterprise.identifier, :id => product.id
      assert_response :redirect
      assert_redirected_to :action => 'index'
      assert assigns(:product)
      assert ! Product.find_by_name('test product')
    end    
  end

  should "fail to destroy product" do
    product = fast_create(Product, :name => 'test product', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    Product.any_instance.stubs(:destroy).returns(false)
    assert_no_difference Product, :count do
      post 'destroy', :profile => @enterprise.identifier, :id => product.id
      assert_response :redirect
      assert_redirected_to :action => 'show'
      assert assigns(:product)
      assert Product.find_by_name('test product')      
    end    
  end

  should 'show categories selection' do
    category1 = fast_create(ProductCategory, :name => 'Category 1')
    category2 = fast_create(ProductCategory, :name => 'Category 2', :parent_id => category1.id)
    category3 = fast_create(ProductCategory, :name => 'Category 3', :parent_id => category2.id)
    get :new, :profile => @enterprise.identifier
    assert_tag :tag => 'select', :attributes => { :id => 'category_id' }, :descendant => { :tag => 'option', :content => category1.name }
  end

  should "create new product categorized" do
    category1 = fast_create(ProductCategory, :name => 'Category 1')
    category2 = fast_create(ProductCategory, :name => 'Category 2', :parent_id => category1)
    assert_difference Product, :count do
      post 'new', :profile => @enterprise.identifier, :product => { :name => 'test product' }, :selected_category_id => category2.id
      assert_equal category2, assigns(:product).product_category
    end
  end

  should 'filter html from name of product' do
    category = fast_create(ProductCategory, :name => 'Category 1')
    post 'new', :profile => @enterprise.identifier, :product => { :name => "<b id='html_name'>name bold</b>" }, :selected_category_id => category.id
    assert_sanitized assigns(:product).name
  end

  should 'filter html with white list from description of product' do
    product = fast_create(Product, :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    post 'edit', :profile => @enterprise.identifier, :id => product.id, :field => 'info', :product => { :name => 'name', :description => "<b id='html_descr'>descr bold</b>" }
    assert_equal "<b>descr bold</b>", assigns(:product).description
  end
  
  should 'not let users in if environment do not let' do
    env = Environment.default
    env.enable('disable_products_for_enterprises')
    env.save!
    @enterprise.environment = env
    @enterprise.save!
    get :index, :profile => @enterprise.identifier

    assert_template 'not_found.rhtml'
  end

  should 'show top level product categories for the user to choose' do
    pc1 = fast_create(ProductCategory, :name => 'test_category1')
    pc2 = fast_create(ProductCategory, :name => 'test_category2')

    get :new, :profile => @enterprise.identifier

    assert_equivalent ProductCategory.top_level_for(pc1.environment), assigns(:categories)
  end

  should 'increase level while navigate on hierarchy categories' do
    category_level0 = fast_create(ProductCategory, :name => 'Products', :environment_id => @environment.id)
    category_level1 = fast_create(ProductCategory, :parent_id => category_level0.id, :name => 'Shoes', :environment_id => @environment.id)
    category_level2 = fast_create(ProductCategory, :parent_id => category_level1.id, :name => 'Athletic Shoes', :environment_id => @environment.id)

    get :categories_for_selection, :profile => @enterprise.identifier, :category_id => category_level0.id
    assert_equal 0, assigns(:level)

    get :categories_for_selection, :profile => @enterprise.identifier, :category_id => category_level1.id
    assert_equal 1, assigns(:level)

    get :categories_for_selection, :profile => @enterprise.identifier, :category_id => category_level2.id
    assert_equal 2, assigns(:level)
  end

  should 'remember the selected category' do
    category0 = fast_create(ProductCategory, :name => 'Products', :environment_id => @environment.id)
    category1 = fast_create(ProductCategory, :name => 'Shoes', :environment_id => @environment.id)

    get :categories_for_selection, :profile => @enterprise.identifier, :category_id => category0.id
    assert_equal category0, assigns(:category)

    get :categories_for_selection, :profile => @enterprise.identifier, :category_id => category1.id
    assert_equal category1, assigns(:category)
  end

  should 'list top level categories when has no category_id' do
    get :categories_for_selection, :profile => @enterprise.identifier

    assert_equal ProductCategory.top_level_for(@environment), assigns(:categories)
  end

  should 'render dialog_error_messages template for invalid product' do
    post :new, :profile => @enterprise.identifier, :product => { :name => 'Invalid product' }
    assert_template 'shared/_dialog_error_messages'
  end

  should 'render redirect_via_javascript template after save' do
    assert_difference Product, :count do
      post :new, :profile => @enterprise.identifier, :product => { :name => 'Invalid product' }, :selected_category_id => @product_category.id
      assert_template 'shared/_redirect_via_javascript'
    end
  end

  should 'show product of enterprise' do
    prod = @enterprise.products.create!(:name => 'Product test', :product_category => @product_category)
    get :show, :id => prod.id, :profile => @enterprise.identifier
    assert_tag :tag => 'h2', :content => /#{prod.name}/
  end

  should 'link back to index from product show' do
    enterprise = Enterprise.create!(:name => 'test_enterprise_1', :identifier => 'test_enterprise_1', :environment => Environment.default)
    prod = enterprise.products.create!(:name => 'Product test', :product_category => @product_category)
    get :show, :id => prod.id, :profile => enterprise.identifier
    assert_tag({
      :tag => 'div',
      :attributes => {
        :class => /main-block/
      },
      :descendant => {
        :tag => 'a',
        :attributes => {
          :href => "/catalog/#{enterprise.identifier}",
        },
        :content => /Back to the product listing/
      }
    })
  end

  should 'not show product price when showing product if not informed' do
    product = fast_create(Product, :name => 'test product', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    get :show, :id => product.id, :profile => @enterprise.identifier

    assert_no_tag :tag => 'span', :attributes => { :class => 'product_price' }, :content => /Price:/
  end

  should 'show product price when showing product if unit was informed' do
    product = fast_create(Product, :name => 'test product', :price => 50.00, :unit_id => fast_create(Unit).id, :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    get :show, :id => product.id, :profile => @enterprise.identifier

    assert_tag :tag => 'span', :attributes => { :class => 'field-name' }, :content => /Price:/
    assert_tag :tag => 'span', :attributes => { :class => 'field-value' }, :content => '$ 50.00'
  end

  should 'show product price when showing product if discount was informed' do
    product = fast_create(Product, :name => 'test product', :price => 50.00, :unit_id => fast_create(Unit).id, :discount => 3.50, :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    get :show, :id => product.id, :profile => @enterprise.identifier

    assert_tag :tag => 'span', :attributes => { :class => 'field-name' }, :content => /List price:/
    assert_tag :tag => 'span', :attributes => { :class => 'field-value' }, :content => '$ 50.00'
    assert_tag :tag => 'span', :attributes => { :class => 'field-name' }, :content => /On sale:/
    assert_tag :tag => 'span', :attributes => { :class => 'field-value' }, :content => '$ 46.50'
  end

  should 'show product price when showing product if unit not informed' do
    product = fast_create(Product, :name => 'test product', :price => 50.00, :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    get :show, :id => product.id, :profile => @enterprise.identifier

    assert_tag :tag => 'span', :attributes => { :class => 'field-name' }, :content => /Price:/
    assert_tag :tag => 'span', :attributes => { :class => 'field-value' }, :content => '$ 50.00'
  end

  should 'display button to add input when product has no input' do
    product = fast_create(Product, :name => 'test product', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    get :show, :id => product.id, :profile => @enterprise.identifier

    assert_tag :tag => 'div', :attributes => { :id => 'display-add-input-button'},
      :descendant => {:tag => 'a', :attributes => { :href => "/myprofile/#{@enterprise.identifier}/manage_products/add_input/#{product.id}", :id => 'add-input-button'},  :content => 'Add the inputs or raw material used by this product'}
  end

  should 'has instance of input list when showing product' do
    product = fast_create(Product, :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    get :show, :id => product.id, :profile => @enterprise.identifier
    assert_equal [], assigns(:inputs)
  end

  should 'remove input of a product' do
    product = fast_create(Product, :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    input = fast_create(Input, :product_id => product.id, :product_category_id => @product_category.id)
    assert_equal [input], product.inputs

    post :remove_input, :id => input.id, :profile => @enterprise.identifier
    product.reload
    assert_equal [], product.inputs
  end

  should 'save inputs order' do
    product = fast_create(Product, :enterprise_id => @enterprise.id)
    first = Input.create!(:product => product, :product_category => fast_create(ProductCategory))
    second = Input.create!(:product => product, :product_category => fast_create(ProductCategory))
    third = Input.create!(:product => product, :product_category => fast_create(ProductCategory))

    assert_equal [first, second, third], product.inputs(true)

    get :order_inputs, :profile => @enterprise.identifier, :id => product, :input => [second.id, third.id, first.id]
    assert_template nil

    assert_equal [second, third, first], product.inputs(true)
  end

  should 'render partial certifiers for selection' do
    get :certifiers_for_selection, :profile => @enterprise.identifier
    assert_template '_certifiers_for_selection'
  end

  should 'not list all the products of enterprise' do
    @enterprise.products = []
    1.upto(12) do |n|
      fast_create(Product, :name => "test product_#{n}", :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    end
    get :index, :profile => @enterprise.identifier
    assert_equal 10, assigns(:products).count
  end

  should 'paginate the manage products list of enterprise' do
    @enterprise.products = []
    1.upto(12) do |n|
      fast_create(Product, :name => "test product_#{n}", :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    end
    get :index, :profile => @enterprise.identifier
    assert_tag :tag => 'a', :attributes => { :rel => 'next', :href => "/myprofile/#{@enterprise.identifier}/manage_products?page=2" }

    get :index, :profile => @enterprise.identifier, :page => 2
    assert_equal 2, assigns(:products).count
  end

  should 'display tabs even if description and inputs are empty and user is allowed' do
    product = fast_create(Product, :name => 'test product', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    get :show, :id => product.id, :profile => @enterprise.identifier

    assert_tag :tag => 'div', :attributes => { :id => "product-#{product.id}-tabs" }
  end

  should 'not display tabs if description and inputs are empty and user is not allowed' do
    not_allowed_person = fast_create(Person)

    login_as not_allowed_person.identifier
    product = fast_create(Product, :name => 'test product', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    get :show, :id => product.id, :profile => @enterprise.identifier

    assert_no_tag :tag => 'div', :attributes => { :id => "product-#{product.id}-tabs" }
  end

  should 'not display tabs if description and inputs are empty and user is not logged in' do
    logout

    product = fast_create(Product, :name => 'test product', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    get :show, :id => product.id, :profile => @enterprise.identifier

    assert_no_tag :tag => 'div', :attributes => { :id => "product-#{product.id}-tabs" }
  end

  should 'display only description tab if inputs are empty and user is not allowed' do
    not_allowed_person = fast_create(Person)

    login_as not_allowed_person.identifier
    product = fast_create(Product, :description => 'This product is very good', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    get :show, :id => product.id, :profile => @enterprise.identifier
    assert_tag :tag => 'div', :attributes => { :id => "product-#{product.id}-tabs" }, :descendant => {:tag => 'a', :attributes => {:href => '#product-description'}, :content => 'Description'}
    assert_no_tag :tag => 'div', :attributes => { :id => "product-#{product.id}-tabs" }, :descendant => {:tag => 'a', :attributes => {:href => '#inputs'}, :content => 'Inputs and raw material'}
  end

  should 'display only inputs tab if description is empty and user is not allowed' do
    not_allowed_person = fast_create(Person)

    login_as not_allowed_person.identifier
    product = fast_create(Product, :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    input = fast_create(Input, :product_id => product.id, :product_category_id => @product_category.id)

    get :show, :id => product.id, :profile => @enterprise.identifier
    assert_no_tag :tag => 'div', :attributes => { :id => "product-#{product.id}-tabs" }, :descendant => {:tag => 'a', :attributes => {:href => '#product-description'}, :content => 'Description'}
    assert_tag :tag => 'div', :attributes => { :id => "product-#{product.id}-tabs" }, :descendant => {:tag => 'a', :attributes => {:href => '#product-inputs'}, :content => 'Inputs and raw material'}
  end

  should 'display tabs if description and inputs are not empty and user is not allowed' do
    not_allowed_person = fast_create(Person)

    login_as not_allowed_person.identifier
    product = fast_create(Product, :description => 'This product is very good', :enterprise_id => @enterprise.id, :product_category_id => @product_category.id)
    input = fast_create(Input, :product_id => product.id, :product_category_id => @product_category.id)

    get :show, :id => product.id, :profile => @enterprise.identifier
    assert_tag :tag => 'div', :attributes => { :id => "product-#{product.id}-tabs" }, :descendant => {:tag => 'a', :attributes => {:href => '#product-description'}, :content => 'Description'}
    assert_tag :tag => 'div', :attributes => { :id => "product-#{product.id}-tabs" }, :descendant => {:tag => 'a', :attributes => {:href => '#product-inputs'}, :content => 'Inputs and raw material'}
  end

end
