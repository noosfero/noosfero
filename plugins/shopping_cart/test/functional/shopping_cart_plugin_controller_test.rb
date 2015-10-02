require 'test_helper'
require_relative '../../controllers/shopping_cart_plugin_controller'

class ShoppingCartPluginControllerTest < ActionController::TestCase

  def setup
    @controller = ShoppingCartPluginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @profile = fast_create(Enterprise)
    @profile.contact_email = 'enterprise@noosfero.org';@profile.save
    @product = fast_create(Product, profile_id: @profile.id)
  end
  attr_reader :profile
  attr_reader :product

  should 'force cookie expiration with explicit path for an empty cart' do
    get :get, id: product.id
    assert @response.headers['Set-Cookie'] =~ /_noosfero_plugin_shopping_cart=; path=\/plugin\/shopping_cart; expires=.*1970.*/

    get :add, id: product.id
    get :remove, id: product.id
    assert @response.headers['Set-Cookie'] =~ /_noosfero_plugin_shopping_cart=; path=\/plugin\/shopping_cart; expires=.*1970.*/
  end

  should 'add a new product to cart' do
    get :add, id: product.id

    assert product_in_cart?(product)
    assert_equal 1, product_quantity(product)
  end

  should 'grow quantity through add' do
    get :add, id: product.id
    assert_equal 1, product_quantity(product)

    get :add, id: product.id
    assert_equal 2, product_quantity(product)
  end

  should 'not add product to cart if it does not exists' do
    assert_nothing_raised { get :add, id: 9999 }

    refute product_in_cart?(product)
    refute response_ok?
    assert_equal 3, reponse_error_code
  end

  should 'remove cart if the product being removed is the last one' do
    get :add, id: product.id
    assert cart?

    get :remove, id: product.id
    refute cart?
  end

  should 'not try to remove a product if there is no cart' do
    instantiate_cart
    refute cart?

    assert_nothing_raised { get :remove, id: 9999 }
    refute response_ok?
    assert_equal 2, reponse_error_code
  end

  should 'just remove product if there are other products on cart' do
    another_product = fast_create(Product, profile_id: profile.id)
    get :add, id: product.id
    get :add, id: another_product.id

    get :remove, id: product.id
    assert cart?
    refute product_in_cart?(product)
  end

  should 'not try to remove a product that is not in the cart' do
    get :add, id: product.id
    assert cart?
    assert_nothing_raised { get :remove, id: 9999 }

    refute response_ok?
    assert_equal 4, reponse_error_code
  end

  should 'not try to list the cart if there is no cart' do
    instantiate_cart
    refute cart?

    assert_nothing_raised { get :list  }
    refute response_ok?
    assert_equal 2, reponse_error_code
  end

  should 'list products without errors' do
    get :add, id: product.id

    assert_nothing_raised { get :list  }
    assert response_ok?
  end

  should 'update the quantity of a product' do
    get :add, id: product.id
    assert_equal 1, product_quantity(product)

    get :update_quantity, id: product.id, quantity: 3
    assert_equal 3, product_quantity(product)
  end

  should 'not try to update quantity the quantity of a product if there is no cart' do
    instantiate_cart
    refute cart?

    assert_nothing_raised { get :update_quantity, id: 9999, quantity: 3 }
    refute response_ok?
    assert_equal 2, reponse_error_code
  end

  should 'not try to update the quantity of a product that is not in the cart' do
    get :add, id: product.id
    assert cart?
    assert_nothing_raised { get :update_quantity, id: 9999, quantity: 3 }

    refute response_ok?
    assert_equal 4, reponse_error_code
  end

  should 'not update the quantity of a product with a invalid value' do
    get :add, id: product.id

    assert_nothing_raised { get :update_quantity, id: product.id, quantity: -1}
    refute response_ok?
    assert_equal 5, reponse_error_code

    assert_nothing_raised { get :update_quantity, id: product.id, quantity: 'asdf'}
    refute response_ok?
    assert_equal 5, reponse_error_code
  end

  should 'clean the cart' do
    another_product = fast_create(Product, profile_id: profile.id)
    get :add, id: product.id
    get :add, id: another_product.id

    assert_nothing_raised {  get :clean }
    refute cart?
  end

  should 'not crash if there is no cart' do
    instantiate_cart
    refute cart?
    assert_nothing_raised {  get :clean  }
  end

  should 'register order on send request' do
    product1 = fast_create(Product, profile_id: profile.id, price: 1.99)
    product2 = fast_create(Product, profile_id: profile.id, price: 2.23)
    @controller.stubs(:cart).returns({ profile_id: profile.id, items: {product1.id => 1, product2.id => 2}})
    assert_difference 'OrdersPlugin::Order.count', 1 do
      xhr :post, :send_request, order: {consumer_data: {name: "Manuel", email: "manuel@ceu.com"}}
    end

    order = OrdersPlugin::Order.last

    assert_equal 1.99, order.products_list[product1.id][:price]
    assert_equal 1, order.products_list[product1.id][:quantity]
    assert_equal 2.23, order.products_list[product2.id][:price]
    assert_equal 2, order.products_list[product2.id][:quantity]
    assert_equal 'ordered', order.status
  end

  should 'register order on send request and not crash if product is not defined' do
    product1 = fast_create(Product, profile_id: profile.id)
    @controller.stubs(:cart).returns({ profile_id: profile.id, items: {product1.id => 1}})
    assert_difference 'OrdersPlugin::Order.count', 1 do
      xhr :post, :send_request, order: {consumer_data: {name: "Manuel", email: "manuel@ceu.com"}}
    end

    order = OrdersPlugin::Order.last

    assert_equal 0, order.products_list[product1.id][:price]
  end

  should 'clean the cart after placing the order' do
    product1 = fast_create(Product, profile_id: profile.id)
    post :add, id: product1.id
    xhr :post, :send_request, order: {consumer_data: {name: "Manuel", email: "manuel@ceu.com"}}
    refute cart?, "cart expected to be empty!"
  end

  should 'not allow buy without any cart' do
    get :buy
    assert_response :redirect
  end

  private

  def json_response
    ActiveSupport::JSON.decode @response.body
  end

  def cart?
    !@controller.send(:cart).nil?
  end

  def product_in_cart?(product)
    @controller.send(:cart) &&
      @controller.send(:cart)[:items] &&
      @controller.send(:cart)[:items].has_key?(product.id)
  end

  def product_quantity(product)
    @controller.send(:cart)[:items][product.id]
  end

  def response_ok?
    json_response['ok']
  end

  def reponse_error_code
    json_response['error']['code']
  end

  # temporary hack...if I don't do this the session stays as an Array instead
  # of a TestSession
  def instantiate_cart
    get :add, id: product.id
    get :remove, id: product.id
  end

end
