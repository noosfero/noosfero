require_relative '../test_helper'

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  all_fixtures
  def setup
#    @controller = CategoriesController.new

    @env = Environment.default
    assert (@cat1 = env.categories.create(:name => 'a test category'))
    assert (@cat1 = env.categories.create(:name => 'another category'))
    @user = User.find_by_login(create_admin_user(@env))
    @person = @user.person
    login_as_rails5(@person.identifier)
  end

  attr_reader :env, :cat1, :cat2, :user, :profile

  def test_index
    get categories_path
    assert_response :success
    assert_template 'index'
    assert_tag :tag => 'a', :attributes => { :href => '/admin/categories/new?type=Category'}
  end

  def test_edit
    get edit_category_path(cat1)
    assert_response :success
    assert_template 'edit'
    assert_equal cat1, assigns(:category)
  end

  def test_edit_save
    post edit_category_path(cat1), params: {:category => { :name => 'new name for category', :display_color => nil }}
    assert_redirected_to :action => 'index'
    assert_equal 'new name for category', Category.find(cat1.id).name
  end

  def test_new_category
    cat = Category.new
    Category.expects(:new).returns(cat)
    get new_categories_path
  end

  def test_new_save
    assert_difference 'Category.count' do
      post new_categories_path, params: {:category => { :name => 'a new category' }}
      assert_redirected_to :action => 'index'
    end
  end

  def test_remove
    cat = create(Category, :name => 'a category to be removed', :environment_id => env.id)
    post remove_category_path(cat)
    assert_redirected_to :action => 'index'
    assert_raise ActiveRecord::RecordNotFound do
      Category.find(cat.id)
    end
  end

  should 'be able to upload a file' do
    assert_difference 'Category.count' do
      post new_categories_path, params: {:category => { :name => 'new category', :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }}
      assert_equal assigns(:category).image.filename, 'rails.png'
    end
  end

  should 'expire categories menu cache when some menu category is updated' do
    cat = create(Category, :name => 'test category in menu', :environment => env, :display_in_menu => true)
    CategoriesController.any_instance.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').at_least_once
    post edit_category_path(cat), params: {:category => { :name => 'new name for category in menu' }}
  end

  should 'not touch categories menu cache whem updated category is not in menu' do
    cat = create(Category, :name => 'test category not in menu', :environment => env, :display_in_menu => false)
    CategoriesController.any_instance.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').never
    post edit_category_path(cat), params: {:category => { :name => 'new name for category not in menu' }}
  end

  should 'expire categories menu cache when new category is created for the menu' do
    CategoriesController.any_instance.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').at_least_once
    post new_categories_path, params: { :category => { :name => 'my new category for the menu', :display_in_menu => '1' }}
  end

  should 'not handle cache when viewing "edit category" screen' do
    cat = create(Category, :name => 'test category in menu', :environment => env, :display_in_menu => true)
    CategoriesController.any_instance.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').never
    get edit_category_path(cat)
  end

  should 'not expire categories menu cache when new category is created, but not for the menu' do
    CategoriesController.any_instance.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').never
    post new_categories_path, params: {:category => { :name => 'my new category for the menu', :display_in_menu => '0' }}
  end

  should 'not handle cache when viewing "new category" screen' do
    CategoriesController.any_instance.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').never
    get new_categories_path
  end

  should 'not expire cache when updating fails' do
    cat = create(Category, :name => 'test category in menu', :environment => env, :display_in_menu => true)
    CategoriesController.any_instance.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').never

    post edit_category_path(cat), params: { :category => { :name => '' }}

    cat.reload
    assert_equal 'test category in menu', cat.name
  end

  should 'not expire cache when creating fails' do
    CategoriesController.any_instance.expects(:expire_fragment).with(:controller => 'public', :action => 'categories_menu').never
    post new_categories_path, params: {:category => { :display_in_menu => '1' }}
  end

  should 'not display color selection if environment.categories_menu is false' do
    env.enable('disable_categories_menu')
    env.save!
    get new_categories_path

    !assert_tag :tag => 'input', :attributes => { :name => "category[display_color]" }
  end

  should 'display color selection if environment.categories_menu is true' do
    env.disable('disable_categories_menu')
    env.save!
    get new_categories_path

    assert_tag :tag => 'input', :attributes => { :name => "category[display_color]" }
  end

  should 'not list regions' do
    env.categories.destroy_all
    c = create(Category, :name => 'Regular category', :environment => env)
    r = create(Region, :name => 'Some region', :environment => env)

    get categories_path
    assert_tag :tag => 'span', :content => c.name
    assert_tag :tag => 'span', :content => r.name
  end

  should 'use parent\'s type to determine subcategory\'s type' do
    parent = create(Region, name: 'Sample category', environment: env)
    post new_categories_path, params: {:parent_id => parent.id, :parent_type => parent.class.name, :category => {:name => 'Subcategory'}}
    sub = Region.find_by_name('Subcategory')
    assert_equal parent.class, sub.class
  end

end
