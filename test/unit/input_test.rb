require File.dirname(__FILE__) + '/../test_helper'

class InputTest < Test::Unit::TestCase

  should 'require product_category' do
    product_category = fast_create(ProductCategory, :name => 'Products')

    input = Input.new
    input.valid?
    assert input.errors.invalid?(:product_category)

    input.product_category = product_category
    input.valid?
    assert !input.errors.invalid?(:product_category)
  end

  should 'require product' do
    product_category = fast_create(ProductCategory, :name => 'Products')
    product = fast_create(Product, :name => 'Computer', :product_category_id => product_category.id)

    input = Input.new
    input.valid?
    assert input.errors.invalid?(:product)

    input.product = product
    input.valid?
    assert !input.errors.invalid?(:product)
  end

end
