require File.dirname(__FILE__) + '/../test_helper'
require 'categories_controller'

# Re-raise errors caught by the controller.
class CategoriesController; def rescue_action(e) raise e end; end

class CategoriesControllerTest < Test::Unit::TestCase
  all_fixtures
  def setup
    @controller = CategoriesController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
    @response   = ActionController::TestResponse.new
   
    @env = Environment.create!(:name => "My test environment")
    Environment.stubs(:default).returns(env)
    assert (@cat1 = env.categories.create(:name => 'a test category'))
    assert (@cat1 = env.categories.create(:name => 'another category'))
    login_as(create_admin_user(@env))
  end

  attr_reader :env, :cat1, :cat2

  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  def test_index
    assert user =  login_as(create_admin_user(Environment.default))
    assert user.person.has_permission?('manage_environment_categories',Environment.default ), "#{user.login} don't have permission to manage_environment_categories in #{Environment.default.name}"
    get :index
    assert_response :success
    assert_template 'index'
    assert_kind_of Array, assigns(:categories)
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
    post :edit, :id => cat1.id, :category => { :name => 'new name for category' }
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
    assert_difference Category, :count do
      post :new, :category => { :name => 'a new category' }
      assert_redirected_to :action => 'index'
    end
  end

  def test_remove
    cat = Category.create!(:name => 'a category to be removed', :environment_id => env.id)
    post :remove, :id => cat.id
    assert_redirected_to :action => 'index'
    assert_raise ActiveRecord::RecordNotFound do
      Category.find(cat.id)
    end
  end

  should 'be able to upload a file' do
    assert_difference Category, :count do
      post :new, :category => { :name => 'new category', :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }
      assert_equal assigns(:category).image.filename, 'rails.png'
    end
  end

  should 'expire categories menu cache when some menu category is updated' do
    cat = Category.create!(:name => 'test category in menu', :environment => Environment.default, :display_in_menu => true)
    @controller.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').once
    post :edit, :id => cat.id, :category => { :name => 'new name for category in menu' }
  end

  should 'not touch categories menu cache whem updated category is not in menu' do
    cat = Category.create!(:name => 'test category not in menu', :environment => Environment.default, :display_in_menu => false)
    @controller.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').never
    post :edit, :id => cat.id, :category => { :name => 'new name for category not in menu' }
  end

  should 'expire categories menu cache when new category is created for the menu' do
    @controller.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').once
    post :new, :category => { :name => 'my new category for the menu', :display_in_menu => '1' }
  end

  should 'not handle cache when viewing "edit category" screen' do
    cat = Category.create!(:name => 'test category in menu', :environment => Environment.default, :display_in_menu => true)
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
    cat = Category.create!(:name => 'test category in menu', :environment => Environment.default, :display_in_menu => true)
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

    assert_no_tag :tag => 'select', :attributes => { :name => "category[display_color]" }
  end

  should 'display color selection if environment.categories_menu is true' do
    env.disable('disable_categories_menu')
    env.save!
    get :new

    assert_tag :tag => 'select', :attributes => { :name => "category[display_color]" }
  end

  should 'not display category_type if only one category is available' do
    env.category_types = ['Category']
    get :new

    assert_no_tag :tag => 'select', :attributes => { :name => "type" }
  end

  should 'have hidden_tag type if only one category is available' do
    env.category_types = ['Category']
    env.save!
    get :new

    assert_tag :tag => 'input', :attributes => { :name => 'type', :value => "Category", :type => 'hidden' }
  end

 should 'display category_type if more than one category is available' do
    env.category_types = 'Category', 'ProductCategory'
    get :new

    assert_tag :tag => 'select', :attributes => { :name => "type" }
  end
end
