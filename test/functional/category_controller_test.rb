require File.dirname(__FILE__) + '/../test_helper'
require 'category_controller'

# Re-raise errors caught by the controller.
class CategoryController; def rescue_action(e) raise e end; end

class CategoryControllerTest < Test::Unit::TestCase
  def setup
    @controller = CategoryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @category = Category.create!(:name => 'my category', :environment => Environment.default)
  end

  def test_should_display_a_given_category
    get :view, :category_path => [ 'my-category' ]
    assert_equal @category, assigns(:category)
  end

  should 'expose category in a method' do
    get :view, :category_path => [ 'my-category' ]
    assert_same assigns(:category), @controller.category
  end

  should 'list recent articles in the category' do
    @controller.expects(:category).returns(@category).at_least_once
    recent = []
    @category.expects(:recent_articles).returns(recent)

    get :view, :category_path => [ 'my-category' ]
    assert_same recent, assigns(:recent_articles)
  end

  should 'list recent comments in the category' do
    @controller.expects(:category).returns(@category).at_least_once
    recent = []
    @category.expects(:recent_comments).returns(recent)

    get :view, :category_path => [ 'my-category' ]
    assert_same recent, assigns(:recent_comments)
  end

  should 'list most commented articles in the category' do
    @controller.expects(:category).returns(@category).at_least_once
    most_commented = []
    @category.expects(:most_commented_articles).returns(most_commented)

    get :view, :category_path => [ 'my-category' ]
    assert_same most_commented, assigns(:most_commented_articles)
  end

  should 'display category of products' do
    cat = ProductCategory.create!(:name => 'Food', :environment => Environment.default)
    get :view, :category_path => cat.path.split('/')
  end

end
