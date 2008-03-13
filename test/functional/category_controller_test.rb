require File.dirname(__FILE__) + '/../test_helper'
require 'category_controller'

# Re-raise errors caught by the controller.
class CategoryController; def rescue_action(e) raise e end; end

class CategoryControllerTest < Test::Unit::TestCase
  def setup
    @controller = CategoryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_display_a_given_category
    category = Category.create!(:name => 'my category', :environment => Environment.default)

    get :view, :path => [ 'my-category' ]
    assert_equal category, assigns(:category)
  end

end
