require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/shopping_cart_plugin_profile_controller'

# Re-raise errors caught by the controller.
class ShoppingCartPluginProfileController; def rescue_action(e) raise e end; end

class ShoppingCartPluginProfileControllerTest < Test::Unit::TestCase

  def setup
    @controller = ShoppingCartPluginProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @enterprise = fast_create(Enterprise)
    @product = fast_create(Product, :enterprise_id => @enterprise.id)
  end
  attr_reader :enterprise
  attr_reader :product

  should 'add a new product to cart' do
    get :add, :profile => enterprise.identifier, :id => product.id

    assert product_in_cart?(product)
    assert_equal 1, product_quantity(product)
  end

  should 'grow quantity through add' do
    get :add, :profile => enterprise.identifier, :id => product.id
    assert_equal 1, product_quantity(product)

    get :add, :profile => enterprise.identifier, :id => product.id
    assert_equal 2, product_quantity(product)
  end

  should 'not add product to cart if it does not exists' do
    assert_nothing_raised { get :add, :profile => enterprise.identifier, :id => 9999 }

    assert !product_in_cart?(product)
    assert !response_ok?
    assert 3, reponse_error_code
  end

  should 'remove cart if the product being removed is the last one' do
    get :add, :profile => enterprise.identifier, :id => product.id
    assert cart?

    get :remove, :profile => enterprise.identifier, :id => product.id
    assert !cart?
  end

  should 'not try to remove a product if there is no cart' do
    instantiate_session
    assert !cart?

    assert_nothing_raised { get :remove, :profile => enterprise.identifier, :id => 9999 }
    assert !response_ok?
    assert_equal 2, reponse_error_code
  end

  should 'just remove product if there are other products on cart' do
    another_product = fast_create(Product, :enterprise_id => enterprise.id)
    get :add, :profile => enterprise.identifier, :id => product.id
    get :add, :profile => enterprise.identifier, :id => another_product.id

    get :remove, :profile => enterprise.identifier, :id => product.id
    assert cart?
    assert !product_in_cart?(product)
  end

  should 'not try to remove a product that is not in the cart' do
    get :add, :profile => enterprise.identifier, :id => product.id
    assert cart?
    assert_nothing_raised { get :remove, :profile => enterprise.identifier, :id => 9999 }

    assert !response_ok?
    assert_equal 4, reponse_error_code
  end

  should 'not try to list the cart if there is no cart' do
    instantiate_session
    assert !cart?

    assert_nothing_raised { get :list, :profile => enterprise.identifier }
    assert !response_ok?
    assert_equal 2, reponse_error_code
  end

  should 'list products without errors' do
    get :add, :profile => enterprise.identifier, :id => product.id

    assert_nothing_raised { get :list, :profile => enterprise.identifier }
    assert response_ok?
  end

  should 'update the quantity of a product' do
    get :add, :profile => enterprise.identifier, :id => product.id
    assert 1, product_quantity(product)

    get :update_quantity, :profile => enterprise.identifier, :id => product.id, :quantity => 3
    assert 3, product_quantity(product)
  end

  should 'not try to update quantity the quantity of a product if there is no cart' do
    instantiate_session
    assert !cart?

    assert_nothing_raised { get :update_quantity, :profile => enterprise.identifier, :id => 9999, :quantity => 3 }
    assert !response_ok?
    assert_equal 2, reponse_error_code
  end

  should 'not try to update the quantity of a product that is not in the cart' do
    get :add, :profile => enterprise.identifier, :id => product.id
    assert cart?
    assert_nothing_raised { get :update_quantity, :profile => enterprise.identifier, :id => 9999, :quantity => 3 }

    assert !response_ok?
    assert_equal 4, reponse_error_code
  end

  should 'not update the quantity of a product with a invalid value' do
    get :add, :profile => enterprise.identifier, :id => product.id

    assert_nothing_raised { get :update_quantity, :profile => enterprise.identifier, :id => product.id, :quantity => -1}
    assert !response_ok?
    assert_equal 5, reponse_error_code

    assert_nothing_raised { get :update_quantity, :profile => enterprise.identifier, :id => product.id, :quantity => 'asdf'}
    assert !response_ok?
    assert_equal 5, reponse_error_code
  end

  should 'clean the cart' do
    another_product = fast_create(Product, :enterprise_id => enterprise.id)
    get :add, :profile => enterprise.identifier, :id => product.id
    get :add, :profile => enterprise.identifier, :id => another_product.id

    assert_nothing_raised {  get :clean, :profile => enterprise.identifier }
    assert !cart?
  end

  should 'not crash if there is no cart' do
    instantiate_session
    assert !cart?
    assert_nothing_raised {  get :clean, :profile => enterprise.identifier }
  end

  should 'register order on send request' do
    product1 = fast_create(Product, :enterprise_id => enterprise.id, :price => 1.99)
    product2 = fast_create(Product, :enterprise_id => enterprise.id, :price => 2.23)
    @controller.stubs(:session).returns({:cart => {:items => {product1.id => 1, product2.id => 2}}})
    assert_difference ShoppingCartPlugin::PurchaseOrder, :count, 1 do
      post :send_request,
        :customer => {:name => "Manuel", :email => "manuel@ceu.com"},
        :profile => enterprise.identifier
    end

    order = ShoppingCartPlugin::PurchaseOrder.last

    assert_equal 1.99, order.products_list[product1.id][:price]
    assert_equal 1, order.products_list[product1.id][:quantity]
    assert_equal 2.23, order.products_list[product2.id][:price]
    assert_equal 2, order.products_list[product2.id][:quantity]
    assert_equal ShoppingCartPlugin::PurchaseOrder::Status::OPENED, order.status
  end

  private

  def json_response
    ActiveSupport::JSON.decode @response.body
  end

  def cart?
    !session[:cart].nil?
  end

  def product_in_cart?(product)
    session[:cart][:items].has_key?(product.id)
  end

  def product_quantity(product)
    session[:cart][:items][product.id]
  end

  def response_ok?
    json_response['ok']
  end

  def reponse_error_code
    json_response['error']['code']
  end

  # temporary hack...if I don't do this the session stays as an Array instead
  # of a TestSession
  def instantiate_session
    get :add, :profile => enterprise.identifier, :id => product.id
    get :remove, :profile => enterprise.identifier, :id => product.id
  end

end
