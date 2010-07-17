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

  include ActionView::Helpers::NumberHelper
  should 'format price to environment currency' do
    @environment.currency_unit = "R$"
    @environment.currency_separator = ","
    @environment.currency_delimiter = "."
    @environment.save
    assert_equal 'R$ 10,00', float_to_currency(10.0)
  end

  should 'not display link to edit product when user does not have permission' do
    user = mock
    user.expects(:has_permission?).with(anything, anything).returns(false)
    @controller = mock
    @controller.expects(:user).returns(user).at_least_once
    @controller.expects(:profile).returns(mock)
    category = fast_create(ProductCategory, :name => 'Category 1', :environment_id => @environment.id)
    product = fast_create(Product, :product_category_id => category.id)
    assert_equal '', edit_product_link(product, 'field', 'link to edit')
  end

  should 'display link to edit product when user has permission' do
    user = mock
    user.expects(:has_permission?).with(anything, anything).returns(true)
    @controller = mock
    @controller.expects(:user).returns(user).at_least_once
    @controller.expects(:profile).returns(mock)
    category = fast_create(ProductCategory, :name => 'Category 1', :environment_id => @environment.id)
    product = fast_create(Product, :product_category_id => category.id)

    expects(:link_to_remote).with('link to edit', {:update => "product-name", :url => {:controller => 'manage_products', :action => 'edit', :id => product.id, :field => 'name'}, :method => :get}, anything).returns('LINK')

    assert_equal 'LINK', edit_product_link(product, 'name', 'link to edit')
  end

  should 'not display link to edit product category when user does not have permission' do
    user = mock
    user.expects(:has_permission?).with(anything, anything).returns(false)
    @controller = mock
    @controller.expects(:user).returns(user).at_least_once
    @controller.expects(:profile).returns(mock)
    category = fast_create(ProductCategory, :name => 'Category 1', :environment_id => @environment.id)
    product = fast_create(Product, :product_category_id => category.id)
    assert_equal '', edit_product_category_link(product)
  end

  should 'display link to edit product category when user has permission' do
    user = mock
    user.expects(:has_permission?).with(anything, anything).returns(true)
    @controller = mock
    @controller.expects(:user).returns(user).at_least_once
    @controller.expects(:profile).returns(mock)
    category = fast_create(ProductCategory, :name => 'Category 1', :environment_id => @environment.id)
    product = fast_create(Product, :product_category_id => category.id)

    assert_tag_in_string edit_product_category_link(product), {:tag => 'a', :content => 'Change category'}
  end

  protected
  include NoosferoTestHelper

end
