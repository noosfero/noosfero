require File.dirname(__FILE__) + '/../test_helper'
require 'manage_products_controller'

# Re-raise errors caught by the controller.
class ManageProductsController; def rescue_action(e) raise e end; end

class ManageProductsControllerTest < Test::Unit::TestCase
  all_fixtures
  def setup
    @controller = ManageProductsController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
    @response   = ActionController::TestResponse.new
    @enterprise = Enterprise.create(:name => 'teste', :identifier => 'test_ent')
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
      post 'new', :profile => @enterprise.identifier, :product => {:name => 'test product', :product_category_id => @product_category.id}
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

  should "get edit form" do
    p = @enterprise.products.create!(:name => 'test product', :product_category => @product_category)
    get 'edit', :profile => @enterprise.identifier, :id => p.id
    assert_response :success
    assert assigns(:product)
    assert_template 'edit'
    assert_tag :tag => 'form', :attributes => { :action => /edit/ }
  end

  should "edit product" do
    p = @enterprise.products.create!(:name => 'test product', :product_category => @product_category)
    post 'edit', :profile => @enterprise.identifier, :product => {:name => 'new test product'}, :id => p.id
    assert_response :redirect
    assert assigns(:product)
    assert ! assigns(:product).new_record?
    assert_equal p, Product.find_by_name('new test product')
  end

  should "not edit to invalid parameters" do
    p = @enterprise.products.create!(:name => 'test product', :product_category => @product_category)
    post 'edit', :profile => @enterprise.identifier, :product => {:product_category => nil}, :id => p.id
    assert_response :success
    assert assigns(:product)
    assert ! assigns(:product).valid?
  end

  should "destroy product" do
    p = @enterprise.products.create!(:name => 'test product', :product_category => @product_category)
    assert_difference Product, :count, -1 do
      post 'destroy', :profile => @enterprise.identifier, :id => p.id
      assert_response :redirect
      assert_redirected_to :action => 'index'
      assert assigns(:product)
      assert ! Product.find_by_name('test product')
    end    
  end

  should "fail to destroy product" do
    p = @enterprise.products.create!(:name => 'test product', :product_category => @product_category)
    Product.any_instance.stubs(:destroy).returns(false)
    assert_no_difference Product, :count do
      post 'destroy', :profile => @enterprise.identifier, :id => p.id
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
      post 'new', :profile => @enterprise.identifier, :product => { :name => 'test product', :product_category_id => category2.id }
      assert_equal category2, assigns(:product).product_category
    end
  end

  should 'show thumbnail image when edit product' do
    p = @enterprise.products.create!(:name => 'test product1', :product_category => @product_category, :image_builder => {
      :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
    })
    get 'edit', :profile => @enterprise.identifier, :id => p.id
    assert_tag :tag => 'img', :attributes => { :src => /#{p.image.public_filename(:thumb)}/ }
  end

  should 'show change image link above thumbnail image' do
    p = @enterprise.products.create!(:name => 'test product1', :product_category => @product_category, :image_builder => {
      :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
    })
    get 'edit', :profile => @enterprise.identifier, :id => p.id
    assert_tag :tag => 'a', :attributes => { :href => '#' }, :content => 'Change image'
  end
  
  should 'filter html from name of product' do
    category = fast_create(ProductCategory, :name => 'Category 1')
    post 'new', :profile => @enterprise.identifier, :product => { :name => "<b id='html_name'>name bold</b>", :product_category_id => category.id }
    assert_sanitized assigns(:product).name
  end

  should 'filter html from description of product' do
    category = fast_create(ProductCategory, :name => 'Category 1')
    post 'new', :profile => @enterprise.identifier, :product => { :name => 'name', :description => "<b id='html_descr'>descr bold</b>", :product_category_id => category.id }
    assert_sanitized assigns(:product).description
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

  should 'links to products asset for product category link when showing' do
    pc = fast_create(ProductCategory, :name => 'test_category')
    p = @enterprise.products.create!(:name => 'test product', :product_category => pc)

    get :show, :profile => @enterprise.identifier, :id => p.id

    assert_tag :tag => 'a', :attributes => {:href => /assets\/products\?product_category=#{pc.id}/}
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
      post :new, :profile => @enterprise.identifier, :product => { :name => 'Invalid product', :product_category_id => @product_category.id }
      assert_template 'shared/_redirect_via_javascript'
    end
  end

end
