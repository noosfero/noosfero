require File.dirname(__FILE__) + '/../../../../test/test_helper'

class ShoppingCartPluginMyprofileControllerTest < ActionController::TestCase

  TIME_FORMAT = '%Y-%m-%d'

  def setup
    @profile = fast_create(Enterprise)
    @admin = create_user('admin').person
    @profile.add_admin(@admin)
    login_as(@admin.identifier)
  end
  attr_reader :profile

  should 'be able to enable shopping cart' do
    settings.enabled = false
    settings.save!
    post :edit, :profile => profile.identifier, :settings => {:enabled => '1'}

    assert settings.enabled
  end

  should 'be able to disable shopping cart' do
    settings.enabled = true
    settings.save!
    post :edit, :profile => profile.identifier, :settings => {:enabled => '0'}

    assert !settings.enabled
  end

  should 'be able to enable shopping cart delivery' do
    settings.delivery = false
    settings.save!
    post :edit, :profile => profile.identifier, :settings => {:delivery => '1'}

    assert settings.delivery
  end

  should 'be able to disable shopping cart delivery' do
    settings.delivery = true
    settings.save!
    post :edit, :profile => profile.identifier, :settings => {:delivery => '0'}

    assert !settings.delivery
  end

  should 'be able to choose the delivery price' do
    price = 4.35
    post :edit, :profile => profile.identifier, :settings => {:delivery_price => price}

    assert settings.delivery_price == price.to_s
  end

  # FIXME
  should 'be able to choose delivery_options' do
    delivery_options = {:options => ['car', 'bike'], :prices => ['20', '5']}
    post :edit, :profile => profile.identifier, :settings => {:delivery_options => delivery_options}

    assert_equal '20', settings.delivery_options['car']
    assert_equal '5', settings.delivery_options['bike']
  end

  should 'filter the reports correctly' do
    another_profile = fast_create(Enterprise)
    po1 = OrdersPlugin::Sale.create! :profile => profile, :status => 'confirmed'
    po2 = OrdersPlugin::Sale.create! :profile => profile, :status => 'shipped'
    po3 = OrdersPlugin::Sale.create! :profile => profile, :status => 'confirmed'
    po3.created_at = 1.year.ago
    po3.save!
    po4 = OrdersPlugin::Sale.create! :profile => another_profile, :status => 'confirmed'

    post :reports,
      :profile => profile.identifier,
      :from => (Time.now - 1.day).strftime(TIME_FORMAT),
      :to => (Time.now + 1.day).strftime(TIME_FORMAT),
      :filter_status => 'confirmed'

    assert_includes assigns(:orders), po1
    assert_not_includes assigns(:orders), po2
    assert_not_includes assigns(:orders), po3
    assert_not_includes assigns(:orders), po4
  end

  should 'group filtered orders products and quantities' do
    p1 = fast_create(Product, :profile_id => profile.id, :price => 1, :name => 'p1')
    p2 = fast_create(Product, :profile_id => profile.id, :price => 2, :name => 'p2')
    p3 = fast_create(Product, :profile_id => profile.id, :price => 3)
    po1_products = {p1.id => {:quantity => 1, :price => p1.price, :name => p1.name}, p2.id => {:quantity => 2, :price => p2.price, :name => p2.name }}
    po2_products = {p2.id => {:quantity => 1, :price => p2.price, :name => p2.name }, p3.id => {:quantity => 2, :price => p3.price, :name => p3.name}}
    po1 = OrdersPlugin::Sale.create! :profile => profile, :products_list => po1_products, :status => 'confirmed'
    po2 = OrdersPlugin::Sale.create! :profile => profile, :products_list => po2_products, :status => 'confirmed'

    post :reports,
      :profile => profile.identifier,
      :from => (Time.now - 1.day).strftime(TIME_FORMAT),
      :to => (Time.now + 1.day).strftime(TIME_FORMAT),
      :filter_status => 'confirmed'

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
    po = OrdersPlugin::Sale.create!(:profile => profile, :status => 'confirmed')

    post :update_order_status,
      :profile => profile.identifier,
      :order_id => po.id,
      :order_status => 'confirmed'
    po.reload
    assert_equal 'confirmed', po.status
  end

  private

  def settings
    @profile.reload
    profile.shopping_cart_settings
  end
end
