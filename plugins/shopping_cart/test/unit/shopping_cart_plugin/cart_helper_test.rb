require 'test_helper'

class ShoppingCartPlugin::CartHelperTest < ActiveSupport::TestCase

  include ShoppingCartPlugin::CartHelper

  def setup
    @product = mock()
    @product.stubs(:name).returns('Sample')
    @product.stubs(:price).returns(nil)
    @product.stubs(:discount).returns(nil)
  end

  attr_reader :product

  should 'return 0 on sell price if the product have no price' do
    assert_equal 0, sell_price(product)
  end

  should 'return the price of the product on sell price if there is no discount' do
    price = 5.73
    product.stubs(:price).returns(price)

    assert_equal price, sell_price(product)
  end

  should 'return the price with discount on sell price if there is a discount' do
    price = 5.73
    discount = 1
    product.stubs(:price).returns(price)
    product.stubs(:discount).returns(discount)
    product.stubs(:price_with_discount).returns(price-discount)

    assert_equal price-discount, sell_price(product)
  end

  should 'return the correct formated string with float_to_currency_cart' do
    value = 13.7
    environment = Environment.default

    assert_equal "#{environment.currency_unit}13#{environment.currency_separator}70", float_to_currency_cart(value,environment)
  end

end
