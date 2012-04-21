require File.dirname(__FILE__) + '/../test_helper'

class PriceDetailTest < ActiveSupport::TestCase

  should 'have price 0 by default' do
    p = PriceDetail.new

    assert p.price.zero?
  end

  should 'return zero on price if it is blank' do
    p = PriceDetail.new(:price => '')

    assert p.price.zero?
  end

  should 'accept price in american\'s or brazilian\'s currency format' do
    [
      [12.34, 12.34],
      ["12.34", 12.34],
      ["12,34", 12.34],
      ["12.345.678,90", 12345678.90],
      ["12,345,678.90", 12345678.90],
      ["12.345.678", 12345678.00],
      ["12,345,678", 12345678.00]
    ].each do |input, output|
      new_price_detail = PriceDetail.new(:price => input)
      assert_equal output, new_price_detail.price
    end
  end

  should 'belongs to a product' do
    p = PriceDetail.new

    assert_respond_to p, :product
  end

  should 'product be mandatory' do
    p = PriceDetail.new
    p.valid?

    assert p.errors.invalid?(:product_id)
  end

  should 'have production cost' do
    product = fast_create(Product)
    cost = fast_create(ProductionCost, :owner_id => Environment.default.id, :owner_type => 'Environment')
    detail = product.price_details.create(:production_cost_id => cost.id, :price => 10)

    assert_equal cost, PriceDetail.find(detail.id).production_cost
  end

  should 'production cost be mandatory' do
    p = PriceDetail.new
    p.valid?

    assert p.errors.invalid?(:production_cost_id)
  end

  should 'th production cost be unique on scope of product' do
    product = fast_create(Product)
    cost = fast_create(ProductionCost, :owner_id => Environment.default.id, :owner_type => 'environment')

    detail1 = product.price_details.create(:production_cost_id => cost.id, :price => 10)
    detail2 = product.price_details.build(:production_cost_id => cost.id, :price => 10)

    detail2.valid?
    assert detail2.errors.invalid?(:production_cost_id)
  end

  should 'format values to float with 2 decimals' do
    enterprise = fast_create(Enterprise)
    product = fast_create(Product, :enterprise_id => enterprise.id)
    cost = fast_create(ProductionCost, :owner_id => Environment.default.id, :owner_type => 'environment')

    price_detail = product.price_details.create(:production_cost_id => cost.id, :price => 10)

    assert_equal "10.00", price_detail.formatted_value(:price)
  end

end
