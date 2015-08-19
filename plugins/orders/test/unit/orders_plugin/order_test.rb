require "test_helper"

class OrdersPlugin::OrderTest < ActiveSupport::TestCase

  def setup
    @order = build(OrdersPlugin::Order)
  end

  should 'report supplier products when distributing aggregate products' do
    env = Environment.create! name: 'megacoop'
    supplier = Enterprise.create! identifier: 'supplier', name: 'supplier', environment: env
    p1 = supplier.products.create! product_category: ProductCategory.create!(name: 'banana', environment: env)
    p2 = supplier.products.create! product_category: ProductCategory.create!(name: 'aipim', environment: env)

    coop = Community.create! identifier: 'blah', name: 'blah', environment: env
    coop.suppliers.create! profile: supplier, consumer: coop
    aggregate_product = SuppliersPlugin::DistributedProduct.new profile: coop
    aggregate_product.sources_from_products.build quantity: 1, from_product: p1, to_product: aggregate_product
    aggregate_product.sources_from_products.build quantity: 5, from_product: p2, to_product: aggregate_product
    aggregate_product.save!

    # hack
    person = coop

    # this also create offered products
    cycle = OrdersCyclePlugin::Cycle.create! name: 'blah', profile: coop, start: Time.now, finish: Time.now+1.day, delivery_start: Time.now+2.days, delivery_finish: Time.now+3.days, status: 'orders'
    sale = cycle.sales.create! profile: person
    sale.items.create! quantity_consumer_ordered: 3, product: aggregate_product

    r = OrdersPlugin::Order.supplier_products_by_suppliers [sale]
    quantities = r.first.last.map(&:quantity_ordered).map(&:to_i)
    assert_equal [3*1,3*5], quantities
  end

  should 'format code with cycle code' do
    @order.save!
    assert_equal "#{@order.cycle.code}.#{@order.attributes['code']}", @order.code
  end

  should 'use as draft default status' do
    @order = create(OrdersPlugin::Order, :status => nil)
    assert_equal 'draft', @order.status
  end

  ###
  # Status
  ###

  should 'define and validate list of statuses' do
    @order.status = 'blah'
    @order.valid?
    assert @order.errors.invalid?('status')

    ['draft', 'planned', 'ordered', 'cancelled'].each do |i|
      @order.status = i
      @order.valid?
      assert !@order.errors.invalid?('status')
    end
  end

  should 'define status question methods' do
    ['draft', 'planned', 'ordered', 'cancelled'].each do |i|
      @order.status = i
      assert @order.send("#{@order.status}?")
    end
  end

  should 'define forgotten and open status' do
    @order.status = 'draft'
    assert @order.draft?
    assert @order.cycle.orders?
    assert @order.open?
    @order.cycle.status = 'closed'
    assert !@order.open?
    assert @order.forgotten?
  end

  should 'return current status using forgotten and open too' do
    @order.status = 'draft'
    assert @order.open?
    assert_equal 'open', @order.current_status
    @order.cycle.status = 'closed'
    assert @order.forgotten?
    assert_equal 'forgotten', @order.current_status
  end

  should 'define status_message method' do
    assert @order.respond_to?(:status_message)
  end

  ###
  # Delivery
  ###

  should 'give default value to supplier delivery if not present' do
    @order.save!
    @order.profile.save!

    @order.cycle.delivery_methods = []
    @order.supplier_delivery = nil
    assert_nil @order.supplier_delivery

    default = @order.cycle.delivery_methods.create! :profile => @order.profile, :name => 'method', :delivery_type => 'deliver'
    assert_equal default, @order.supplier_delivery
    assert_equal default.id, @order.supplier_delivery_id
  end

  ###
  # Totals
  ###

  should 'give total price and quantity asked' do
    @order.cycle.profile.save!
    product = create(SuppliersPlugin::DistributedProduct, :price => 2.0, :profile => @order.cycle.profile, :supplier => @order.cycle.profile.self_supplier)
    @order.save!
    @order.item.create! :product => @order.cycle.products.first, :quantity_consumer_ordered => 2.0
    assert_equal 2.0, @order.total_quantity_consumer_ordered
    assert_equal 4.0, @order.total_price_consumer_ordered
  end

end
