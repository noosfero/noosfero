# encoding: UTF-8
require_relative "../test_helper"

class ManageProductsHelperTest < ActionView::TestCase

  include ManageProductsHelper
  include ContentViewerHelper
  include ActionView::Helpers::AssetTagHelper
  include ApplicationHelper

  def setup
    stubs(:show_date).returns('')
    @environment = Environment.default
    @profile = create_user('blog_helper_test').person
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
    assert_equal '', edit_product_link_to_remote(product, 'field', 'link to edit')
  end

  should 'display link to edit product when user has permission' do
    user = mock
    user.expects(:has_permission?).with(anything, anything).returns(true)
    @controller = mock
    @controller.expects(:user).returns(user).at_least_once
    @controller.expects(:profile).returns(mock)
    category = fast_create(ProductCategory, :name => 'Category 1', :environment_id => @environment.id)
    product = fast_create(Product, :product_category_id => category.id)

    expects(:link_to_remote).with('link to edit', {:update => "product-name", :loading => "loading_for_button('#link-edit-product-name')", :url => {:controller => 'manage_products', :action => 'edit', :id => product.id, :field => 'name'}, :method => :get}, anything).returns('LINK')

    assert_equal 'LINK', edit_product_link_to_remote(product, 'name', 'link to edit')
  end

  should 'not display link to edit product category when user does not have permission' do
    user = mock
    user.expects(:has_permission?).with(anything, anything).returns(false)
    @controller = mock
    @controller.expects(:user).returns(user).at_least_once
    @controller.expects(:profile).returns(mock)
    category = fast_create(ProductCategory, :name => 'Category 1', :environment_id => @environment.id)
    product = fast_create(Product, :product_category_id => category.id)
    assert_equal '', edit_link('link to edit category', { :action => 'edit_category', :id => product.id })
  end

  should 'display link to edit product category when user has permission' do
    user = mock
    user.expects(:has_permission?).with(anything, anything).returns(true)
    @controller = mock
    @controller.expects(:user).returns(user).at_least_once
    @controller.expects(:profile).returns(mock)
    category = fast_create(ProductCategory, :name => 'Category 1', :environment_id => @environment.id)
    product = fast_create(Product, :product_category_id => category.id)

    expects(:link_to).with('link to edit category', { :action => 'edit_category', :id => product.id }, {} ).returns('LINK')

    assert_equal 'LINK', edit_link('link to edit category', { :action => 'edit_category', :id => product.id })
  end

  should 'not display ui_button to edit product when user does not have permission' do
    user = mock
    user.expects(:has_permission?).with(anything, anything).returns(false)
    @controller = mock
    @controller.expects(:user).returns(user).at_least_once
    @controller.expects(:profile).returns(mock)
    category = fast_create(ProductCategory, :name => 'Category 1', :environment_id => @environment.id)
    product = fast_create(Product, :product_category_id => category.id)
    assert_equal '', edit_ui_button(product, 'field', 'link to edit')
  end

  should 'display ui_button_to_remote to edit product when user has permission' do
    user = mock
    user.expects(:has_permission?).with(anything, anything).returns(true)
    @controller = mock
    @controller.expects(:user).returns(user).at_least_once
    @controller.expects(:profile).returns(mock)
    category = fast_create(ProductCategory, :name => 'Category 1', :environment_id => @environment.id)
    product = fast_create(Product, :product_category_id => category.id)

    expects(:ui_button_to_remote).with('link to edit', {:update => "product-info", :url => {:controller => 'manage_products', :action => 'edit', :id => product.id, :field => 'info'}, :complete => "jQuery('#edit-product-button-ui-info').hide()", :method => :get, :loading => "loading_for_button('#edit-product-remote-button-ui-info')", }, :id => 'edit-product-remote-button-ui-info').returns('LINK')

    assert_equal 'LINK', edit_product_ui_button_to_remote(product, 'info', 'link to edit')
  end


  should 'display ui_button to edit product when user has permission' do
    user = mock
    user.expects(:has_permission?).with(anything, anything).returns(true)
    @controller = mock
    @controller.expects(:user).returns(user).at_least_once
    @controller.expects(:profile).returns(mock)
    category = fast_create(ProductCategory, :name => 'Category 1', :environment_id => @environment.id)
    product = fast_create(Product, :product_category_id => category.id)

    expects(:ui_button).with('link to edit', { :action => 'add_input', :id => product.id }, {}).returns('LINK')

    assert_equal 'LINK', edit_ui_button('link to edit', {:action => 'add_input', :id => product.id})
  end

  should 'show unit on label of amount selection' do
    input = build(Input)
    input.expects(:product).returns(build(Product, :unit => Unit.new(:singular => 'Meter')))
    assert_equal 'Amount used by meter of this product or service', label_amount_used(input)
  end

  should 'not show unit on label of amount selection if product has no unit selected' do
    input = build(Input)
    input.expects(:product).returns(Product.new)
    assert_equal 'Amount used in this product or service', label_amount_used(input)
  end

  should 'sort qualifiers by name' do
    fast_create(Qualifier, :name => 'Organic')
    fast_create(Qualifier, :name => 'Non Organic')
    result = qualifiers_for_select
    assert_equal ["Select...", "Non Organic", "Organic"], result.map{|i| i[0]}
  end

  should 'sort certifiers by name' do
    qualifier = fast_create(Qualifier, :name => 'Organic')
    fbes = fast_create(Certifier, :name => 'FBES')
    colivre = fast_create(Certifier, :name => 'Colivre')
    create(QualifierCertifier, :qualifier => qualifier, :certifier => colivre)
    create(QualifierCertifier, :qualifier => qualifier, :certifier => fbes)

    result = certifiers_for_select(qualifier)
    assert_equal ["Self declared", "Colivre", "FBES"], result.map{|i| i[0]}
  end

  should 'list qualifiers and certifiers of a product' do
    product = fast_create(Product)
    qualifier = fast_create(Qualifier)
    certifier = fast_create(Certifier)
    create(ProductQualifier, :product => product, :qualifier => qualifier, :certifier => certifier)
    assert_match /✔ Qualifier \d+ certified by Certifier \d+/, display_qualifiers(product)
  end

  should 'product survive to a Qualifier deletation' do
    product = fast_create(Product)
    qualifier = fast_create(Qualifier)
    certifier = fast_create(Certifier)
    create(ProductQualifier, :product => product, :qualifier => qualifier, :certifier => certifier)
    qualifier.destroy
    assert_nothing_raised do
      assert_no_match /✔ Qualifier \d+ certified by Certifier \d+/, display_qualifiers(product)
    end
  end

  should 'delete product Qualifier self-declared when Certifier is deleted' do
    product = fast_create(Product)
    qualifier = fast_create(Qualifier)
    certifier = fast_create(Certifier)
    create(ProductQualifier, :product => product, :qualifier => qualifier, :certifier => certifier)
    certifier.destroy
    assert_nothing_raised do
      result = display_qualifiers(product)
      assert_match /✔ Qualifier \d+ \(Self declared\)/, result
      assert_no_match /certified by Certifier \d+/, result
    end
  end

  protected
  include NoosferoTestHelper
  include ActionView::Helpers::TextHelper
end
