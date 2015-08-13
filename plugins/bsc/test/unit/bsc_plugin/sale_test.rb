require 'test_helper'

class BscPlugin::SaleTest < ActiveSupport::TestCase
  def setup
    @sale = BscPlugin::Sale.new
  end

  attr_accessor :sale

  should 'validate presence of product and contract' do
    sale.valid?

    assert sale.errors.invalid?(:product)
    assert sale.errors.invalid?(:contract)

    product = Product.new
    contract = BscPlugin::Contract.new
    sale.product = product
    sale.contract = contract

    refute sale.errors.invalid?(product)
    refute sale.errors.invalid?(contract)
  end

  should 'validate uniqueness of product and contract composed' do
    product = fast_create(Product)
    contract = BscPlugin::Contract.create!(:bsc => BscPlugin::Bsc.new, :client_name => 'Marvin')
    sale1 = BscPlugin::Sale.create!(:product => product, :contract => contract, :quantity => 1)
    sale2 = BscPlugin::Sale.new(:product => product, :contract => contract, :quantity => 1)
    sale2.valid?

    assert sale2.errors.invalid?(:product_id)
  end

  should 'validate quantity as a positive integer' do
    sale.quantity = -1
    sale.valid?
    assert sale.errors.invalid?(:quantity)

    sale.quantity = 1.5
    sale.valid?
    assert sale.errors.invalid?(:quantity)

    sale.quantity = 3
    sale.valid?
    refute sale.errors.invalid?(:quantity)
  end

  should 'set default price as product price if no price indicated' do
    product = fast_create(Product, :price => 3.50)
    contract = BscPlugin::Contract.create!(:bsc => BscPlugin::Bsc.new, :client_name => 'Marvin')
    sale.product = product
    sale.contract = contract
    sale.quantity = 1
    sale.save!

    assert_equal product.price, sale.price
  end

  should 'not overwrite with the product price if price informed' do
    product = fast_create(Product, :price => 3.50)
    contract = BscPlugin::Contract.create!(:bsc => BscPlugin::Bsc.new, :client_name => 'Marvin')
    sale.product = product
    sale.contract = contract
    sale.quantity = 1
    sale.price = 2.50
    sale.save!

    assert_equal  2.50, sale.price
  end

  should 'have default value for price' do
    product1 = fast_create(Product, :price => 1)
    product2 = fast_create(Product, :price => 1)
    product3 = fast_create(Product)
    contract = BscPlugin::Contract.create!(:bsc => BscPlugin::Bsc.new, :client_name => 'Marvin')
    sale1 = BscPlugin::Sale.create!(:price => 2, :product => product1, :contract => contract, :quantity => 1)
    sale2 = BscPlugin::Sale.create!(:product => product2, :contract => contract, :quantity => 1)
    sale3 = BscPlugin::Sale.create!(:product => product3, :contract => contract, :quantity => 1)

    assert_equal 2, sale1.price
    assert_equal 1, sale2.price
    assert_equal 0, sale3.price
  end
end

