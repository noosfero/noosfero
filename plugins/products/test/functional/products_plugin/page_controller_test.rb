require_relative '../../test_helper'
require_relative '../../../models/products_plugin/product_category'

class PageControllerTest < ActionDispatch::IntegrationTest

  all_fixtures

  def setup
    @enterprise       = fast_create Enterprise, name: 'teste', identifier: 'test_ent'
    @environment      = @enterprise.environment
    @user             = create_user_with_permission 'test_user', 'manage_products', @enterprise
    @product_category = create ProductCategory, name: 'Root Category', environment_id: @environment.id
    @unit             = Unit.create environment: @environment

    login_as_rails5 :test_user
  end

  should "not have permission" do
    u = create_user('user_test')
    logout_rails5
    login_as_rails5 :user_test
    get  products_plugin_page_path(@enterprise.identifier, action: :index)
    assert :success
    assert_template 'shared/access_denied'
  end

  should "get index" do
    get  products_plugin_page_path(@enterprise.identifier, action: :index)
    assert_response :success
    assert assigns(:products)
  end

  should "get new form" do
    get products_plugin_page_path(@enterprise.identifier, action: :new)
    assert_response :success
    assert assigns(:product)
    assert_template 'new'
    assert_tag tag: 'form', attributes: { action: /new/ }
  end

  should "create new product" do
    assert_difference 'Product.count' do
      post products_plugin_page_path(@enterprise.identifier, action: :new), params: {product: {name: 'test product'}, selected_category_id: @product_category.id}
      assert assigns(:product)
      refute assigns(:product).new_record?
    end
  end

  should "not create invalid product" do
    assert_no_difference 'Product.count' do
      post products_plugin_page_path(@enterprise.identifier, action: :new), params: {product: {name: 'test product'}}
      assert_response :success
      assert assigns(:product)
      assert assigns(:product).new_record?
    end
  end

  should "get edit name form" do
    product = fast_create(Product, name: 'test product', profile_id: @enterprise.id, product_category_id: @product_category.id)
    get products_plugin_page_path(@enterprise.identifier, action: :edit), params: {id: product.id, field: 'name'}
    assert_response :success
    assert assigns(:product)
    assert_tag tag: 'form', attributes: { action: /profile\/#{@enterprise.identifier}\/plugin\/products\/page\/edit\/#{product.id}\?field=name/ }
  end

  should "get edit info form" do
    product = fast_create(Product, name: 'test product', profile_id: @enterprise.id, product_category_id: @product_category.id)
    get products_plugin_page_path(@enterprise.identifier, action: :edit), params: { id: product.id, field: 'info'}
    assert_response :success
    assert assigns(:product)
    assert_tag tag: 'form', attributes: { action: /profile\/#{@enterprise.identifier}\/plugin\/products\/page\/edit\/#{product.id}\?field=info/ }
  end

  should "get edit image form" do
    product = fast_create(Product, name: 'test product', profile_id: @enterprise.id, product_category_id: @product_category.id)
    get products_plugin_page_path(@enterprise.identifier, action: :edit), params: { id: product.id, field: 'image'}
    assert_response :success
    assert assigns(:product)
    assert_tag tag: 'form', attributes: { action: /profile\/#{@enterprise.identifier}\/plugin\/products\/page\/edit\/#{product.id}\?field=image/ }
  end

  should "edit product name" do
    product = fast_create(Product, name: 'test product', profile_id: @enterprise.id, product_category_id: @product_category.id)
    post products_plugin_page_path(@enterprise.identifier, action: :edit), params: {products_plugin_product: {name: 'new test product'}, id: product.id, field: 'name'}
    assert_response :success
    assert assigns(:product)
    refute  assigns(:product).new_record?
    assert_equal product, Product.find_by(name: 'new test product')
  end

  should "edit product description" do
    product = fast_create(Product, name: 'test product', profile_id: @enterprise.id, product_category_id: @product_category.id, description: 'My product is very good')
    post products_plugin_page_path(@enterprise.identifier, action: :edit), params: {products_plugin_product: {description: 'A very good product!'}, id: product.id, field: 'info'}
    assert_response :success
    assert assigns(:product)
    refute  assigns(:product).new_record?
    assert_equal 'A very good product!', Product.find_by(name: 'test product').description
  end

  should "edit product image" do
    product = fast_create(Product, name: 'test product', profile_id: @enterprise.id, product_category_id: @product_category.id)
    post products_plugin_page_path(@enterprise.identifier, action: :edit), params: {products_plugin_product: { image_builder: { uploaded_data: fixture_file_upload('/files/rails.png', 'image/png') } }, id: product.id, field: 'image'}
    assert_response :success
    assert assigns(:product)
    refute  assigns(:product).new_record?
    assert_equal 'rails.png', Product.find_by(name: 'test product').image.filename
  end

  should "not edit to invalid parameters" do
    product = fast_create(Product, profile_id: @enterprise.id, product_category_id: @product_category.id)
    post products_plugin_page_path(@enterprise.identifier, action: :edit_category), params: {selected_category_id: nil, id: product.id}
    assert_response :success
    assert_template 'shared/_dialog_error_messages'
  end

  should "not crash if product has no category" do
    product = fast_create(Product, profile_id: @enterprise.id)
    assert_nothing_raised do
      post products_plugin_page_path(@enterprise.identifier, action: :edit_category), params: {id: product.id}
    end
  end

  should "destroy product" do
    product = fast_create(Product, name: 'test product', profile_id: @enterprise.id, product_category_id: @product_category.id)
    assert_difference 'Product.count', -1 do
      post products_plugin_page_path(@enterprise.identifier, action: :destroy), params: {id: product.id}
      assert_response :redirect
      assert_redirected_to action: 'index'
      assert assigns(:product)
      refute  Product.find_by(name: 'test product')
    end
  end

  should "fail to destroy product" do
    product = fast_create(Product, name: 'test product', profile_id: @enterprise.id, product_category_id: @product_category.id)
    Product.any_instance.stubs(:destroy).returns(false)
    assert_no_difference 'Product.count' do
      post products_plugin_page_path(@enterprise.identifier, action: :destroy), params: {id: product.id}
      assert_response :redirect
      assert_redirected_to controller: "products_plugin/page", profile: @enterprise.identifier, action: 'show', id: product.id
      assert assigns(:product)
      assert Product.find_by(name: 'test product')
    end
  end

  should 'show categories selection' do
    create ProductCategory, name: 'Category 2', parent_id: @product_category.id
    get products_plugin_page_path(@enterprise.identifier, action: :new)
    assert_tag tag: 'select', attributes: { id: 'category_id' }, descendant: { tag: 'option', content: /#{@product_category.name}/ }
  end

  should "create new product categorized" do
    category2 = fast_create(ProductCategory, name: 'Category 2', parent_id: @product_category)
    assert_difference 'Product.count' do
      post products_plugin_page_path(@enterprise.identifier, action: :new), params: { product: { name: 'test product' }, selected_category_id: category2.id}
      assert_equal category2, assigns(:product).product_category
    end
  end

  should 'not create a new product with an invalid category' do
    category2 = create(Category, name: 'Category 2', parent_id: @product_category)
    assert_raise ActiveRecord::AssociationTypeMismatch do
      post products_plugin_page_path(@enterprise.identifier, action: :new), params: { product: { name: 'test product' }, selected_category_id: category2.id}
    end
  end

  should 'filter html from name of product' do
    post products_plugin_page_path(@enterprise.identifier, action: :new), params: {products_plugin_product: { name: "<b id='html_name'>name bold</b>" }, selected_category_id: @product_category.id}
    assert_sanitized assigns(:product).name
  end

  should 'filter html with white list from description of product' do
    product = fast_create(Product, profile_id: @enterprise.id, product_category_id: @product_category.id)
    post products_plugin_page_path(@enterprise.identifier, action: :edit), params: {id: product.id, field: 'info', products_plugin_product: { name: 'name', description: "<b id=\"html_descr\">descr bold</b>" }}
    assert_equal "<b id=\"html_descr\">descr bold</b>", assigns(:product).description
  end

  should 'show top level product categories for the user to choose' do
    pc2 = create(ProductCategory, name: 'test_category2')

    get products_plugin_page_path(@enterprise.identifier, action: :new)

    assert_equivalent ProductCategory.top_level_for(@product_category.environment), assigns(:categories)
  end

  should 'increase level while navigate on hierarchy categories' do
    category_level1 = create ProductCategory, parent_id: @product_category.id, name: 'Shoes', environment_id: @environment.id
    category_level2 = create ProductCategory, parent_id: category_level1.id, name: 'Athletic Shoes', environment_id: @environment.id

    get products_plugin_page_path(@enterprise.identifier, action: :categories_for_selection), params: {category_id: nil}
    assert_equal 0, assigns(:level)

    get products_plugin_page_path(@enterprise.identifier, action: :categories_for_selection), params: {category_id: @product_category.id}
    assert_equal 1, assigns(:level)

    get products_plugin_page_path(@enterprise.identifier, action: :categories_for_selection), params: {category_id: category_level1.id}
    assert_equal 2, assigns(:level)
  end

  should 'remember the selected category' do
    category2 = create ProductCategory, name: 'Shoes', environment_id: @environment.id

    get products_plugin_page_path(@enterprise.identifier, action: :categories_for_selection), params: {category_id: @product_category.id}
    assert_equal @product_category, assigns(:category)

    get products_plugin_page_path(@enterprise.identifier, action: :categories_for_selection), params: { category_id: category2.id}
    assert_equal category2, assigns(:category)
  end

  should 'list top level categories when has no category_id' do
    get products_plugin_page_path(@enterprise.identifier, action: :categories_for_selection)

    assert_equal ProductCategory.top_level_for(@environment), assigns(:categories)
  end

  should 'render dialog_error_messages template for invalid product' do
    post  products_plugin_page_path(@enterprise.identifier, action: :new), params: {product: { name: 'Invalid product' }}
    assert_template 'shared/_dialog_error_messages'
  end

  should 'show product of enterprise' do
    prod = @enterprise.products.create!(name: 'Product test', product_category: @product_category)
    get products_plugin_page_path(@enterprise.identifier, action: :show), params: {id: prod.id}
    assert_tag tag: 'h2', content: /#{prod.name}/
  end

  should 'link back to index from product show' do
    enterprise = create(Enterprise, name: 'test_enterprise_1', identifier: 'test_enterprise_1', environment: Environment.default)
    prod = enterprise.products.create!(name: 'Product test', product_category: @product_category)
    get products_plugin_page_path(enterprise.identifier, action: :show), params: { id: prod.id}
    assert_tag({
      tag: 'a',
      attributes: {
        href: /profile\/#{enterprise.identifier}\/plugin\/products\/catalog/
      },
      content: /Back to the product listing/,
    })
  end

  should 'not show product price when showing product if not informed' do
    product = fast_create(Product, name: 'test product', profile_id: @enterprise.id, product_category_id: @product_category.id)
    get products_plugin_page_path(@enterprise.identifier, action: :show), params: { id: product.id}

    !assert_tag tag: 'span', attributes: { class: 'product_price' }, content: /Price:/
  end

  should 'show product price when showing product if unit was informed' do
    product = fast_create(Product, name: 'test product', price: 50.00, unit_id: @unit.id, profile_id: @enterprise.id, product_category_id: @product_category.id)
    get products_plugin_page_path(@enterprise.identifier, action: :show), params: { id: product.id}

    assert_tag tag: 'span', attributes: { class: 'field-name' }, content: /Price:/
    assert_tag tag: 'span', attributes: { class: 'field-value' }, content: '$ 50.00'
  end

  should 'show product price when showing product if discount was informed' do
    product = fast_create(Product, name: 'test product', price: 50.00, unit_id: @unit.id, discount: 3.50, profile_id: @enterprise.id, product_category_id: @product_category.id)
    get  products_plugin_page_path(@enterprise.identifier, action: :show), params: { id: product.id}

    assert_tag tag: 'span', attributes: { class: 'field-name' }, content: /List price:/
    assert_tag tag: 'span', attributes: { class: 'field-value' }, content: '$ 50.00'
    assert_tag tag: 'span', attributes: { class: 'field-name' }, content: /On sale:/
    assert_tag tag: 'span', attributes: { class: 'field-value' }, content: '$ 46.50'
  end

  should 'show product price when showing product if unit not informed' do
    product = fast_create(Product, name: 'test product', price: 50.00, profile_id: @enterprise.id, product_category_id: @product_category.id)
    get  products_plugin_page_path(@enterprise.identifier, action: :show), params: { id: product.id}

    assert_tag tag: 'span', attributes: { class: 'field-name' }, content: /Price:/
    assert_tag tag: 'span', attributes: { class: 'field-value' }, content: '$ 50.00'
  end

  should 'display button to add input when product has no input' do
    product = fast_create(Product, name: 'test product', profile_id: @enterprise.id, product_category_id: @product_category.id)
    get  products_plugin_page_path(@enterprise.identifier, action: :show), params: { id: product.id}

    assert_tag tag: 'div', attributes: { id: 'display-add-input-button'},
      descendant: {tag: 'a', attributes: { href: /\/profile\/#{@enterprise.identifier}\/plugin\/products\/page\/add_input\/#{product.id}/, id: 'add-input-button'},  content: 'Add the inputs or raw material used by this product'}
  end

  should 'has instance of input list when showing product' do
    product = fast_create(Product, profile_id: @enterprise.id, product_category_id: @product_category.id)
    get  products_plugin_page_path(@enterprise.identifier, action: :show), params: { id: product.id}
    assert_equal [], assigns(:inputs)
  end

  should 'remove input of a product' do
    product = fast_create(Product, profile_id: @enterprise.id, product_category_id: @product_category.id)
    input = fast_create(Input, product_id: product.id, product_category_id: @product_category.id)
    assert_equal [input], product.inputs

    post   products_plugin_page_path(@enterprise.identifier, action: :remove_input), params: { id: input.id}
    product.reload
    assert_equal [], product.inputs
  end

  should 'save inputs order' do
    product = fast_create(Product, profile_id: @enterprise.id)
    first = Input.create!(product: product, product_category: fast_create(ProductCategory))
    second = Input.create!(product: product, product_category: fast_create(ProductCategory))
    third = Input.create!(product: product, product_category: fast_create(ProductCategory))

    inputs = [first.id, second.id, third.id]
    
    assert_equal inputs, product.inputs.map{|i|i.id}

    get  products_plugin_page_path(@enterprise.identifier, action: :order_inputs), params: { id: product.id, input: inputs}
    assert_template nil

    assert_equal inputs, product.inputs.map{|i|i.id}
  end

  should 'render partial certifiers for selection' do
    get products_plugin_page_path(@enterprise.identifier, action: :certifiers_for_selection), xhr: true
    assert_template 'certifiers_for_selection'
  end

  should 'not list all the products of enterprise' do
    @enterprise.products = []
    1.upto(12) do |n|
      fast_create(Product, name: "test product_#{n}", profile_id: @enterprise.id, product_category_id: @product_category.id)
    end
    get  products_plugin_page_path(@enterprise.identifier, action: :index)
    assert_equal 10, assigns(:products).size
  end

  should 'paginate the manage products list of enterprise' do
    @enterprise.products = []
    1.upto(12) do |n|
      fast_create(Product, name: "test product_#{n}", profile_id: @enterprise.id, product_category_id: @product_category.id)
    end
    get  products_plugin_page_path(@enterprise.identifier, action: :index)
    assert_tag tag: 'a', attributes: { rel: 'next', href: "/profile/#{@enterprise.identifier}/plugin/products/page?page=2" }

    get products_plugin_page_path(@enterprise.identifier, action: :index), params: {page: 2}
    assert_equal 2, assigns(:products).size
  end

  should 'display tabs even if description and inputs are empty and user is allowed' do
    product = fast_create(Product, name: 'test product', profile_id: @enterprise.id, product_category_id: @product_category.id)
    get  products_plugin_page_path(@enterprise.identifier, action: :show), params: { id: product.id}

    assert_tag tag: 'div', attributes: { id: "product-#{product.id}-tabs" }
  end

  should 'not display tabs if description and inputs are empty and user is not allowed' do
    create_user('foo')

    login_as_rails5 'foo'

    product = fast_create(Product, name: 'test product', profile_id: @enterprise.id, product_category_id: @product_category.id)
    get  products_plugin_page_path(@enterprise.identifier, action: :show), params: {id: product.id}

    !assert_tag tag: 'div', attributes: { id: "product-#{product.id}-tabs" }
  end

  should 'not display tabs if description and inputs are empty and user is not logged in' do
    logout

    product = fast_create(Product, name: 'test product', profile_id: @enterprise.id, product_category_id: @product_category.id)
    get  products_plugin_page_path(@enterprise.identifier, action: :show), params: {id: product.id}

    !assert_tag tag: 'div', attributes: { id: "product-#{product.id}-tabs" }
  end

  should 'display only description tab if inputs are empty and user is not allowed' do
    create_user('foo')

    login_as_rails5 'foo'
    product = fast_create(Product, description: 'This product is very good', profile_id: @enterprise.id, product_category_id: @product_category.id)
    get  products_plugin_page_path(@enterprise.identifier, action: :show), params: { id: product.id}
    assert_tag tag: 'div', attributes: { id: "product-#{product.id}-tabs" }, descendant: {tag: 'a', attributes: {href: '#product-description'}, content: 'Description'}
    !assert_tag tag: 'div', attributes: { id: "product-#{product.id}-tabs" }, descendant: {tag: 'a', attributes: {href: '#inputs'}, content: 'Inputs and raw material'}
  end

  should 'display only inputs tab if description is empty and user is not allowed' do
    create_user 'foo'

    login_as_rails5 'foo'
    product = fast_create(Product, profile_id: @enterprise.id, product_category_id: @product_category.id)
    input = fast_create(Input, product_id: product.id, product_category_id: @product_category.id)

    get  products_plugin_page_path(@enterprise.identifier, action: :show), params: { id: product.id}
    !assert_tag tag: 'div', attributes: { id: "product-#{product.id}-tabs" }, descendant: {tag: 'a', attributes: {href: '#product-description'}, content: 'Description'}
    assert_tag tag: 'div', attributes: { id: "product-#{product.id}-tabs" }, descendant: {tag: 'a', attributes: {href: '#product-inputs'}, content: 'Inputs and raw material'}
  end

  should 'display tabs if description and inputs are not empty and user is not allowed' do
    create_user('foo')

    login_as_rails5 'foo'
    product = fast_create(Product, description: 'This product is very good', profile_id: @enterprise.id, product_category_id: @product_category.id)
    input = fast_create(Input, product_id: product.id, product_category_id: @product_category.id)

    get  products_plugin_page_path(@enterprise.identifier, action: :show), params: { id: product.id}
    assert_tag tag: 'div', attributes: { id: "product-#{product.id}-tabs" }, descendant: {tag: 'a', attributes: {href: '#product-description'}, content: 'Description'}
    assert_tag tag: 'div', attributes: { id: "product-#{product.id}-tabs" }, descendant: {tag: 'a', attributes: {href: '#product-inputs'}, content: 'Inputs and raw material'}
  end

  should 'include extra content supplied by plugins on products info extras' do
    class TestProductInfoExtras1Plugin < Noosfero::Plugin
      def product_info_extras(p)
        proc {"<span id='plugin1'>This is Plugin1 speaking!</span>".html_safe}
      end
    end
    class TestProductInfoExtras2Plugin < Noosfero::Plugin
      def product_info_extras(p)
        proc { "<span id='plugin2'>This is Plugin2 speaking!</span>".html_safe}
      end
    end

    product = fast_create(Product, profile_id: @enterprise.id)

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestProductInfoExtras1Plugin.new, TestProductInfoExtras2Plugin.new])

    get  products_plugin_page_path(@enterprise.identifier, action: :show), params: {id: product.id}

    assert_tag tag: 'span', content: 'This is Plugin1 speaking!', attributes: {id: 'plugin1'}
    assert_tag tag: 'span', content: 'This is Plugin2 speaking!', attributes: {id: 'plugin2'}
  end

  should 'not allow product creation for profiles that can\'t do it' do
    class SpecialEnterprise < Enterprise
      def create_product?
        false
      end
    end
    enterprise = SpecialEnterprise.create!(identifier: 'special-enterprise', name: 'Special Enterprise')
    get products_plugin_page_path(enterprise.identifier, action: :new)
    assert_response 403
  end

  should 'remove price detail of a product' do
    product = fast_create(Product, profile_id: @enterprise.id, product_category_id: @product_category.id)
    cost = fast_create(ProductionCost, owner_id: Environment.default.id, owner_type: 'Environment')
    detail = product.price_details.create(production_cost_id: cost.id, price: 10)

    assert_equal [detail], product.price_details

    post products_plugin_page_path(@enterprise.identifier, action: :remove_price_detail), params: {id: detail.id, product: product.id}
    product.reload
    assert_equal [], product.price_details
  end

  should 'create a production cost for enterprise' do
    get products_plugin_page_path(@enterprise.identifier, action: :create_production_cost), params: {id: 'Taxes'}

    assert_equal ['Taxes'], Enterprise.find(@enterprise.id).production_costs.map(&:name)
    resp = ActiveSupport::JSON.decode(@response.body)
    assert_equal 'Taxes', resp['name']
    assert resp['id'].kind_of?(Integer)
    assert resp['ok']
    assert_nil resp['error_msg']
  end

  should 'display error if production cost has no name' do
    get products_plugin_page_path(@enterprise.identifier, action: :create_production_cost)

    resp = ActiveSupport::JSON.decode(@response.body)
    assert_nil resp['name']
    assert_nil resp['id']
    refute resp['ok']
    assert_match /blank/, resp['error_msg']
  end

  should 'display error if name of production cost is too long' do
    get  products_plugin_page_path(@enterprise.identifier, action: :create_production_cost), params: {id: 'a'*60}

    resp = ActiveSupport::JSON.decode(@response.body)
    assert_nil resp['name']
    assert_nil resp['id']
    refute resp['ok']
    assert_match /too long/, resp['error_msg']
  end

end
