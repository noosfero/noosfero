require "#{File.dirname(__FILE__)}/../../test_helper"

class OrdersCyclePlugin::ProfileTest < ActiveRecord::TestCase

  def setup
    @profile = build(Profile)
    @invisible_profile = build(Enterprise, :visible => false)
    @other_profile = build(Enterprise)
    @profile = build(OrdersCyclePlugin::profile, :profile => @profile)
    @self_supplier = build(OrdersCyclePlugin::Supplier, :consumer => @profile, :profile => @profile)
    @dummy_supplier = build(OrdersCyclePlugin::Supplier, :consumer => @profile, :profile => @dummy_profile)
    @other_supplier = build(OrdersCyclePlugin::Supplier, :consumer => @profile, :profile => @other_profile)
  end

  attr_accessor :profile, :invisible_profile, :other_profile,
    :self_supplier, :dummy_supplier, :other_supplier

  should 'respond to name methods' do
    profile.expects(:name).returns('name')
    assert_equal 'name', profile.name
  end

  should 'respond to dummy methods' do
    profile.dummy = true
    assert_equal true, profile.dummy?
    profile.dummy = false
    assert_equal false, profile.dummy
  end

  should "return closed cycles' date range" do
    DateTime.expects(:now).returns(1).at_least_once
    assert_equal 1..1, profile.orders_cycles_closed_date_range
    s1 = create(OrdersCyclePlugin::Cycle, :profile => profile, :start => Time.now-1.days, :finish => nil)
    s2 = create(OrdersCyclePlugin::Cycle, :profile => profile, :finish => Time.now+1.days, :start => Time.now)
    assert_equal (s1.start.to_date..s2.finish.to_date), profile.orders_cycles_closed_date_range
  end

  should 'return abbreviation or the name' do
    profile.name_abbreviation = 'coll.'
    profile.profile.name = 'collective'
    assert_equal 'coll.', profile.abbreviation_or_name
    profile.name_abbreviation = nil
    assert_equal 'collective', profile.abbreviation_or_name
  end

  ###
  # Products
  ###

  should "default products's margins when asked" do
    profile.update! :margin_percentage => 10
    product = create(SuppliersPlugin::DistributedProduct, :profile => profile, :supplier => profile.self_supplier,
                     :price => 10, :default_margin_percentage => false)
    cycle = create(OrdersCyclePlugin::Cycle, :profile => profile)
    sproduct = cycle.products.first
    sproduct.update! :margin_percentage => 5
    cycleclosed = create(OrdersCyclePlugin::Cycle, :profile => profile, :status => 'closed')

    profile.orders_cycles_products_default_margins
    product.reload
    sproduct.reload
    assert_equal true, product.default_margin_percentage
    assert_equal sproduct.margin_percentage, profile.margin_percentage
  end

  should 'return not yet distributed products' do
    profile.save!
    other_profile.save!
    other_supplier.save!
    product = create(SuppliersPlugin::DistributedProduct, :profile => other_profile, :supplier => other_profile.self_supplier)
    profile.add_supplier_products other_supplier
    product2 = create(SuppliersPlugin::DistributedProduct, :profile => other_profile, :supplier => other_profile.self_supplier)
    assert_equal [product2], profile.not_distributed_products(other_supplier)
  end

  ###
  # Suppliers
  ###

  should 'add supplier' do
    @profile.save!
    @other_profile.save!

    assert_difference OrdersCyclePlugin::Supplier, :count do
      @profile.add_supplier @other_profile
    end
    assert @profile.suppliers_profiles.include?(@other_profile)
    assert @other_profile.consumers_profiles.include?(@profile)
  end

  should "add all supplier's products when supplier is added" do
    @profile.save!
    @other_profile.save!
    product = create(SuppliersPlugin::DistributedProduct, :profile => @other_profile)
    @profile.add_supplier @other_profile
    assert_equal [product], @profile.from_products
  end

  should 'remove supplier' do
    @profile.save!
    @other_profile.save!

    @profile.add_supplier @other_profile
    assert_difference OrdersCyclePlugin::Supplier, :count, -1 do
      assert_difference RoleAssignment, :count, -1 do
        @profile.remove_supplier @other_profile
      end
    end
    assert !@profile.suppliers_profiles.include?(@other_profile)
  end

  should "archive supplier's products when supplier is removed" do
    @profile.save!
    @other_profile.save!
    product = create(SuppliersPlugin::DistributedProduct, :profile => @other_profile)
    @profile.add_supplier @other_profile
    @profile.remove_supplier @other_profile
    assert_equal [product], @profile.from_products
    assert_equal 1, @profile.distributed_products.archived.count
  end

  should 'create self supplier automatically' do
    profile = create(OrdersCyclePlugin::profile, :profile => @profile)
    assert_equal 1, profile.suppliers.count
  end

end
