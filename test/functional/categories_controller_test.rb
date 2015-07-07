require_relative "../test_helper"
require 'categories_controller'

class CategoriesControllerTest < ActionController::TestCase
  all_fixtures
  def setup
    @controller = CategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @env = fast_create(Environment, :name => "My test environment")
    Environment.stubs(:default).returns(env)
    assert (@cat1 = env.categories.create(:name => 'a test category'))
    assert (@cat1 = env.categories.create(:name => 'another category'))
    login_as(create_admin_user(@env))
  end

  attr_reader :env, :cat1, :cat2

  def test_index
    login_as(create_admin_user(Environment.default))
    get :index
    assert_response :success
    assert_template 'index'
    assert_tag :tag => 'a', :attributes => { :href => '/admin/categories/new'}
  end

  def test_edit
    cat = Category.new
    env.categories.expects(:find).with('1').returns(cat)
    get :edit, :id => '1'
    assert_response :success
    assert_template 'edit'
    assert_equal cat, assigns(:category)
  end

  def test_edit_save
    post :edit, :id => cat1.id, :category => { :name => 'new name for category', :display_color => nil }
    assert_redirected_to :action => 'index'
    assert_equal 'new name for category', Category.find(cat1.id).name
  end

  def test_new_category
    cat = Category.new
    Category.expects(:new).returns(cat)
    get :new
  end

  def test_new_product_category
    cat = ProductCategory.new
    ProductCategory.expects(:new).returns(cat)
    get :new, :type => 'ProductCategory'
  end

  def test_new_save
    assert_difference 'Category.count' do
      post :new, :category => { :name => 'a new category' }
      assert_redirected_to :action => 'index'
    end
  end

  def test_remove
    cat = create(Category, :name => 'a category to be removed', :environment_id => env.id)
    post :remove, :id => cat.id
    assert_redirected_to :action => 'index'
    assert_raise ActiveRecord::RecordNotFound do
      Category.find(cat.id)
    end
  end

  should 'be able to upload a file' do
    assert_difference 'Category.count' do
      post :new, :category => { :name => 'new category', :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }
      assert_equal assigns(:category).image.filename, 'rails.png'
    end
  end

  should 'expire categories menu cache when some menu category is updated' do
    cat = create(Category, :name => 'test category in menu', :environment => Environment.default, :display_in_menu => true)
    @controller.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').at_least_once
    post :edit, :id => cat.id, :category => { :name => 'new name for category in menu' }
  end

  should 'not touch categories menu cache whem updated category is not in menu' do
    cat = create(Category, :name => 'test category not in menu', :environment => Environment.default, :display_in_menu => false)
    @controller.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').never
    post :edit, :id => cat.id, :category => { :name => 'new name for category not in menu' }
  end

  should 'expire categories menu cache when new category is created for the menu' do
    @controller.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').at_least_once
    post :new, :category => { :name => 'my new category for the menu', :display_in_menu => '1' }
  end

  should 'not handle cache when viewing "edit category" screen' do
    cat = create(Category, :name => 'test category in menu', :environment => Environment.default, :display_in_menu => true)
    @controller.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').never
    get :edit, :id => cat.id
  end

  should 'not expire categories menu cache when new category is created, but not for the menu' do
    @controller.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').never
    post :new, :category => { :name => 'my new category for the menu', :display_in_menu => '0' }
  end

  should 'not handle cache when viewing "new category" screen' do
    @controller.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').never
    get :new
  end

  should 'not expire cache when updating fails' do
    cat = create(Category, :name => 'test category in menu', :environment => Environment.default, :display_in_menu => true)
    @controller.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').never

    post :edit, :id => cat.id, :category => { :name => '' }

    cat.reload
    assert_equal 'test category in menu', cat.name
  end

  should 'not expire cache when creating fails' do
    @controller.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').never
    post :new, :category => { :display_in_menu => '1' }
  end

  should 'not display color selection if environment.categories_menu is false' do
    env.enable('disable_categories_menu')
    env.save!
    get :new

    assert_no_tag :tag => 'input', :attributes => { :name => "category[display_color]" }
  end

  should 'display color selection if environment.categories_menu is true' do
    env.disable('disable_categories_menu')
    env.save!
    get :new

    assert_tag :tag => 'input', :attributes => { :name => "category[display_color]" }
  end

  should 'not list regions and product categories' do
    Environment.default.categories.destroy_all
    c = create(Category, :name => 'Regular category', :environment => Environment.default)
    p = create(ProductCategory, :name => 'Product category', :environment => Environment.default)
    r = create(Region, :name => 'Some region', :environment => Environment.default)

    get :index
    assert_equal [c], assigns(:categories)
    assert_equal [p], assigns(:product_categories)
    assert_equal [r], assigns(:regions)
  end

  should 'use parent\'s type to determine subcategory\'s type' do
    parent = create(ProductCategory, :name => 'Sample category', :environment => Environment.default)
    post :new, :parent_id => parent.id, :parent_type => parent.class.name, :category => {:name => 'Subcategory'}
    sub = ProductCategory.find_by_name('Subcategory')
    assert_equal parent.class, sub.class
  end

end
