require File.dirname(__FILE__) + '/../../../../test/test_helper'

class ShoppingCartPluginMyprofileControllerTest < ActionController::TestCase

  TIME_FORMAT = '%Y-%m-%d'

  def setup
    @enterprise = fast_create(Enterprise)
    @admin = create_user('admin').person
    @enterprise.add_admin(@admin)
    login_as(@admin.identifier)
  end
  attr_reader :enterprise

  should 'be able to enable shopping cart' do
    settings.enabled = false
    settings.save!
    post :edit, :profile => enterprise.identifier, :settings => {:enabled => '1'}

    assert settings.enabled
  end

  should 'be able to disable shopping cart' do
    settings.enabled = true
    settings.save!
    post :edit, :profile => enterprise.identifier, :settings => {:enabled => '0'}

    assert !settings.enabled
  end

  should 'be able to enable shopping cart delivery' do
    settings.delivery = false
    settings.save!
    post :edit, :profile => enterprise.identifier, :settings => {:delivery => '1'}

    assert settings.delivery
  end

  should 'be able to disable shopping cart delivery' do
    settings.delivery = true
    settings.save!
    post :edit, :profile => enterprise.identifier, :settings => {:delivery => '0'}

    assert !settings.delivery
  end

  should 'be able to choose the delivery price' do
    price = 4.35
    post :edit, :profile => enterprise.identifier, :settings => {:delivery_price => price}

    assert settings.delivery_price == price
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
    p1 = fast_create(Product, :enterprise_id => enterprise.id, :price => 1, :name => 'p1')
    p2 = fast_create(Product, :enterprise_id => enterprise.id, :price => 2, :name => 'p2')
    p3 = fast_create(Product, :enterprise_id => enterprise.id, :price => 3)
    po1_products = {p1.id => {:quantity => 1, :price => p1.price, :name => p1.name}, p2.id => {:quantity => 2, :price => p2.price, :name => p2.name }}
    po2_products = {p2.id => {:quantity => 1, :price => p2.price, :name => p2.name }, p3.id => {:quantity => 2, :price => p3.price, :name => p3.name}}
    po1 = ShoppingCartPlugin::PurchaseOrder.create!(:seller => enterprise, :products_list => po1_products, :status => ShoppingCartPlugin::PurchaseOrder::Status::OPENED)
    po2 = ShoppingCartPlugin::PurchaseOrder.create!(:seller => enterprise, :products_list => po2_products, :status => ShoppingCartPlugin::PurchaseOrder::Status::OPENED)

    post :reports,
      :profile => enterprise.identifier,
      :from => (Time.now - 1.day).strftime(TIME_FORMAT),
      :to => (Time.now + 1.day).strftime(TIME_FORMAT),
      :filter_status => ShoppingCartPlugin::PurchaseOrder::Status::OPENED

    lineitem1 = ShoppingCartPlugin::LineItem.new(p1.id, p1.name)
    lineitem1.quantity = 1
    lineitem2 = ShoppingCartPlugin::LineItem.new(p2.id, p2.name)
    lineitem2.quantity = 3
    lineitem3 = ShoppingCartPlugin::LineItem.new(p3.id, p3.name)
    lineitem3.quantity = 2
    hash = {p1.id => lineitem1, p2.id => lineitem2, p3.id => lineitem3}

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

  private

  def settings
    @enterprise.reload
    Noosfero::Plugin::Settings.new(@enterprise, ShoppingCartPlugin)
  end
end
