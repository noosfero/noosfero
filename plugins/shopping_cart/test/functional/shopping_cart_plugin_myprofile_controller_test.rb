require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/shopping_cart_plugin_myprofile_controller'

# Re-raise errors caught by the controller.
class ShoppingCartPluginMyprofileController; def rescue_action(e) raise e end; end

class ShoppingCartPluginMyprofileControllerTest < ActionController::TestCase

  TIME_FORMAT = '%Y-%m-%d'

  def setup
    @controller = ShoppingCartPluginMyprofileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @enterprise = fast_create(Enterprise)
    @admin = create_user('admin').person
    @enterprise.add_admin(@admin)
    login_as(@admin.identifier)
  end
  attr_reader :enterprise

  should 'be able to enable shopping cart' do
    enterprise.shopping_cart = false
    enterprise.save
    post :edit, :profile => enterprise.identifier, :profile_attr => {:shopping_cart => '1'}
    enterprise.reload

    assert enterprise.shopping_cart
  end

  should 'be able to disable shopping cart' do
    enterprise.shopping_cart = true
    enterprise.save
    post :edit, :profile => enterprise.identifier, :profile_attr => {:shopping_cart => '0'}
    enterprise.reload

    assert !enterprise.shopping_cart
  end

  should 'be able to enable shopping cart delivery' do
    enterprise.shopping_cart_delivery = false
    enterprise.save
    post :edit, :profile => enterprise.identifier, :profile_attr => {:shopping_cart_delivery => '1'}
    enterprise.reload

    assert enterprise.shopping_cart_delivery
  end

  should 'be able to disable shopping cart delivery' do
    enterprise.shopping_cart_delivery = true
    enterprise.save
    post :edit, :profile => enterprise.identifier, :profile_attr => {:shopping_cart_delivery => '0'}
    enterprise.reload

    assert !enterprise.shopping_cart_delivery
  end

  should 'be able to choose the delivery price' do
    price = 4.35
    post :edit, :profile => enterprise.identifier, :profile_attr => {:shopping_cart_delivery_price => price}
    enterprise.reload
    assert enterprise.shopping_cart_delivery_price == price
  end

  should 'filter the reports correctly' do
    another_enterprise = fast_create(Enterprise)
    po1 = ShoppingCartPlugin::PurchaseOrder.create!(:seller => enterprise, :status => ShoppingCartPlugin::PurchaseOrder::Status::OPENED)
    po2 = ShoppingCartPlugin::PurchaseOrder.create!(:seller => enterprise, :status => ShoppingCartPlugin::PurchaseOrder::Status::SHIPPED)
    po3 = ShoppingCartPlugin::PurchaseOrder.create!(:seller => enterprise, :status => ShoppingCartPlugin::PurchaseOrder::Status::OPENED)
    po3.created_at = 1.year.ago
    po3.save!
    po4 = ShoppingCartPlugin::PurchaseOrder.create!(:seller => another_enterprise, :status => ShoppingCartPlugin::PurchaseOrder::Status::OPENED)

    post :reports,
      :profile => enterprise.identifier,
      :from => (Time.now - 1.day).strftime(TIME_FORMAT),
      :to => (Time.now + 1.day).strftime(TIME_FORMAT),
      :filter_status => ShoppingCartPlugin::PurchaseOrder::Status::OPENED

    assert_includes assigns(:orders), po1
    assert_not_includes assigns(:orders), po2
    assert_not_includes assigns(:orders), po3
    assert_not_includes assigns(:orders), po4
  end

  should 'group filtered orders products and quantities' do
    p1 = fast_create(Product, :enterprise_id => enterprise.id, :price => 1)
    p2 = fast_create(Product, :enterprise_id => enterprise.id, :price => 2)
    p3 = fast_create(Product, :enterprise_id => enterprise.id, :price => 3)
    po1_products = {p1.id => {:quantity => 1, :price => p1.price}, p2.id => {:quantity => 2, :price => p2.price }}
    po2_products = {p2.id => {:quantity => 1, :price => p2.price}, p3.id => {:quantity => 2, :price => p3.price }}
    po1 = ShoppingCartPlugin::PurchaseOrder.create!(:seller => enterprise, :products_list => po1_products, :status => ShoppingCartPlugin::PurchaseOrder::Status::OPENED)
    po2 = ShoppingCartPlugin::PurchaseOrder.create!(:seller => enterprise, :products_list => po2_products, :status => ShoppingCartPlugin::PurchaseOrder::Status::OPENED)

    post :reports,
      :profile => enterprise.identifier,
      :from => (Time.now - 1.day).strftime(TIME_FORMAT),
      :to => (Time.now + 1.day).strftime(TIME_FORMAT),
      :filter_status => ShoppingCartPlugin::PurchaseOrder::Status::OPENED

    hash = {p1.id => 1, p2.id => 3, p3.id => 2}

    assert_equal hash, assigns(:products)
  end

  should 'be able to update the order status' do
    po = ShoppingCartPlugin::PurchaseOrder.create!(:seller => enterprise, :status => ShoppingCartPlugin::PurchaseOrder::Status::OPENED)

    post :update_order_status,
      :profile => enterprise.identifier,
      :order_id => po.id,
      :order_status => ShoppingCartPlugin::PurchaseOrder::Status::CONFIRMED
    po.reload
    assert_equal ShoppingCartPlugin::PurchaseOrder::Status::CONFIRMED, po.status
  end
end
