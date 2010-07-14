require File.dirname(__FILE__) + '/../test_helper'

class ManageProductsHelperTest < Test::Unit::TestCase

  include ManageProductsHelper
  include ContentViewerHelper
  include ActionView::Helpers::AssetTagHelper
  include ApplicationHelper

  def setup
    stubs(:show_date).returns('')
    @environment = Environment.default
    @profile = create_user('blog_helper_test').person
  end

  should 'omit second category when lenght of all names is over 60 chars' do
    category_1 = fast_create(ProductCategory, :name => ('Category 1' * 5), :environment_id => @environment.id)
    category_2 = fast_create(ProductCategory, :name => ('Category 2' * 5), :environment_id => @environment.id, :parent_id => category_1.id)
    category_3 = fast_create(ProductCategory, :name => ('Category 3' * 5), :environment_id => @environment.id, :parent_id => category_2.id)

    assert_match /Category 1/, hierarchy_category_navigation(category_3)
    assert_no_match /Category 2/, hierarchy_category_navigation(category_3)
  end

  should 'show dots when lenght of all names is over 60 chars' do
    category_1 = fast_create(ProductCategory, :name => ('Category 1' * 5), :environment_id => @environment.id)
    category_2 = fast_create(ProductCategory, :name => ('Category 2' * 5), :environment_id => @environment.id, :parent_id => category_1.id)
    category_3 = fast_create(ProductCategory, :name => ('Category 3' * 5), :environment_id => @environment.id, :parent_id => category_2.id)

    assert_match /…/, hierarchy_category_navigation(category_3)
  end

  should 'display select for categories' do
    category_1 = fast_create(ProductCategory, :name => 'Category 1', :environment_id => @environment.id)
    fast_create(ProductCategory, :name => 'Category 2.1', :environment_id => @environment.id, :parent_id => category_1.id)
    fast_create(ProductCategory, :name => 'Category 2.2', :environment_id => @environment.id, :parent_id => category_1.id)

    assert_tag_in_string select_for_categories(category_1.children(true), 1), :tag => 'select', :attributes => {:id => 'category_id'}
  end

  protected
  include NoosferoTestHelper

end
