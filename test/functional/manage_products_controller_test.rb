require File.dirname(__FILE__) + '/../test_helper'
require 'manage_products_controller'

# Re-raise errors caught by the controller.
class ManageProductsController; def rescue_action(e) raise e end; end

class ManageProductsControllerTest < Test::Unit::TestCase
  all_fixtures
  def setup
    @controller = ManageProductsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @enterprise = Enterprise.create(:name => 'teste', :identifier => 'test_ent')
    @user = create_user_with_permission('test_user', 'manage_products', @enterprise)
    login_as :test_user
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
      post 'new', :profile => @enterprise.identifier, :product => {:name => 'test product'}
      assert_response :redirect
      assert assigns(:product)
      assert ! assigns(:product).new_record?
    end
  end

  should "not create invalid product" do
    assert_no_difference Product, :count do
      post 'new', :profile => @enterprise.identifier, :product => {:price => 'test product'}
      assert_response :success
      assert assigns(:product)
      assert assigns(:product).new_record?
    end
  end

  should "get edit form" do
    p = @enterprise.products.create(:name => 'test product')
    get 'edit', :profile => @enterprise.identifier, :id => p.id
    assert_response :success
    assert assigns(:product)
    assert_template 'edit'
    assert_tag :tag => 'form', :attributes => { :action => /edit/ }
  end

  should "edit product" do
    p = @enterprise.products.create(:name => 'test product')
    post 'edit', :profile => @enterprise.identifier, :product => {:name => 'new test product'}, :id => p.id
    assert_response :redirect
    assert assigns(:product)
    assert ! assigns(:product).new_record?
    assert_equal p, Product.find_by_name('new test product')
  end

  should "not edit to invalid parameters" do
    p = @enterprise.products.create(:name => 'test product')
    post 'edit', :profile => @enterprise.identifier, :product => {:name => ''}, :id => p.id
    assert_response :success
    assert assigns(:product)
    assert ! assigns(:product).valid?
  end

  should "destroy product" do
    p = @enterprise.products.create(:name => 'test product')
    assert_difference Product, :count, -1 do
      post 'destroy', :profile => @enterprise.identifier, :id => p.id
      assert_response :redirect
      assert_redirected_to :action => 'index'
      assert assigns(:product)
      assert ! Product.find_by_name('test product')
    end    
  end

  should "fail to destroy product" do
    p = @enterprise.products.create(:name => 'test product')
    Product.any_instance.stubs(:destroy).returns(false)
    assert_no_difference Product, :count do
      post 'destroy', :profile => @enterprise.identifier, :id => p.id
      assert_response :redirect
      assert_redirected_to :action => 'show'
      assert assigns(:product)
      assert Product.find_by_name('test product')      
    end    
  end

  should 'show current category' do
    environment = Environment.default
    category1 = ProductCategory.create!(:name => 'Category 1', :environment => environment)
    category2 = ProductCategory.create!(:name => 'Category 2', :environment => environment, :parent => category1)
    category3 = ProductCategory.create!(:name => 'Category 3', :environment => environment, :parent => category2)
    category4 = ProductCategory.create!(:name => 'Category 4', :environment => environment, :parent => category3)
    get :new, :profile => @enterprise.identifier
    assert_tag :tag => 'p', :content => /Current category:/, :sibling => { :tag => 'a', :content => /#{category1.name}/ }
  end

  should 'show subcategories list' do
    environment = Environment.default
    category1 = ProductCategory.create!(:name => 'Category 1', :environment => environment)
    category2 = ProductCategory.create!(:name => 'Category 2', :environment => environment, :parent => category1)
    get 'new', :profile => @enterprise.identifier
    assert !assigns(:categories).empty?
    assert_tag :tag => 'p', :content => /Select a subcategory:/, :sibling => { :tag => 'a', :attributes => { :href => '#' }, :content => /#{category2.name}/ }
  end

  should 'update subcategories' do
    environment = Environment.default
    category1 = ProductCategory.create!(:name => 'Category 1', :environment => environment)
    category2 = ProductCategory.create!(:name => 'Category 2', :environment => environment, :parent => category1)
    get 'update_subcategories', :profile => @enterprise.identifier, :id => category1.id
    assert_tag :tag => 'a', :attributes => { :href => '#' }, :content => /#{category2.name}/
  end

  should 'not show subcategories list when no subcategories' do
    environment = Environment.default
    category1 = ProductCategory.create!(:name => 'Category 1', :environment => environment)
    get 'update_subcategories', :profile => @enterprise.identifier, :id => category1.id
    assert_no_tag :tag => 'p', :content => 'Select a subcategory:'
  end

  should "create new product categorized" do
    environment = Environment.default
    category1 = ProductCategory.create!(:name => 'Category 1', :environment => environment)
    category2 = ProductCategory.create!(:name => 'Category 2', :environment => environment, :parent => category1)
    assert_difference Product, :count do
      post 'new', :profile => @enterprise.identifier, :product => { :name => 'test product', :product_category_id => category2.id }
      assert_equal category2, assigns(:product).product_category
    end
  end

  should 'show thumbnail image when edit product' do
    p = @enterprise.products.create!(:name => 'test product1', :image_builder => {
      :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
    })
    get 'edit', :profile => @enterprise.identifier, :id => p.id
    assert_tag :tag => 'img', :attributes => { :src => /#{p.image.public_filename(:thumb)}/ }
  end

  should 'show change image link above thumbnail image' do
    p = @enterprise.products.create!(:name => 'test product1', :image_builder => {
      :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
    })
    get 'edit', :profile => @enterprise.identifier, :id => p.id
    assert_tag :tag => 'a', :attributes => { :href => '#' }, :content => 'Change image'
  end
  
  should 'show change image field when new product' do
    get 'new', :profile => @enterprise.identifier
    assert_tag :tag => 'input', :attributes => { :type => 'file', :name => 'product[image_builder][uploaded_data]' }
  end

  should 'filter html from name of product' do
    category = ProductCategory.create!(:name => 'Category 1', :environment => Environment.default)
    post 'new', :profile => @enterprise.identifier, :product => { :name => "<b id='html_name'>name bold</b>", :product_category_id => category.id }
    assert_sanitized assigns(:product).name
  end

  should 'filter html from description of product' do
    category = ProductCategory.create!(:name => 'Category 1', :environment => Environment.default)
    post 'new', :profile => @enterprise.identifier, :product => { :name => 'name', :description => "<b id='html_descr'>descr bold</b>", :product_category_id => category.id }
    assert_sanitized assigns(:product).description
  end

end
