require File.dirname(__FILE__) + '/../test_helper'
require 'categories_controller'

# Re-raise errors caught by the controller.
class CategoriesController; def rescue_action(e) raise e end; end

class CategoriesControllerTest < Test::Unit::TestCase

  def setup
    @controller = CategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
   
    @env = Environment.create!(:name => "My test environment")
    Environment.stubs(:default).returns(env)
    assert (@cat1 = env.categories.create(:name => 'a test category'))
    assert (@cat1 = env.categories.create(:name => 'another category'))
  end
  attr_reader :env, :cat1, :cat2

  def test_index
    get :index
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


end
