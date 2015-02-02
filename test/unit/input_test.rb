require_relative "../test_helper"

class InputTest < ActiveSupport::TestCase

  should 'require product_category' do
    product_category = fast_create(ProductCategory, :name => 'Products')

    input = Input.new
    input.valid?
    assert input.errors[:product_category.to_s].present?

    input.product_category = product_category
    input.valid?
    assert !input.errors[:product_category.to_s].present?
  end

  should 'require product' do
    product_category = fast_create(ProductCategory, :name => 'Products')
    product = fast_create(Product, :name => 'Computer', :product_category_id => product_category.id)

    input = Input.new
    input.valid?
    assert input.errors[:product.to_s].present?

    input.product = product
    input.valid?
    assert !input.errors[:product.to_s].present?
  end

  should 'store inputs ordered by position' do
    product_category = fast_create(ProductCategory)
    product = fast_create(Product, :product_category_id => product_category.id)

    first_input = create(Input, :product => product, :product_category => product_category)
    assert_equal 1, first_input.position

    second_input = create(Input, :product => product, :product_category => product_category)
    assert_equal 2, second_input.position
  end

  should 'move input to top of input list' do
    product_category = fast_create(ProductCategory)
    product = fast_create(Product, :product_category_id => product_category.id)

    first_input = create(Input, :product => product, :product_category => product_category)
    second_input = create(Input, :product => product, :product_category => product_category)
    last_input = create(Input, :product => product, :product_category => product_category)

    assert_equal [first_input, second_input, last_input], product.inputs(true)

    last_input.move_to_top

    assert_equal [last_input, first_input, second_input], product.inputs(true)
  end

  should 'use name of product category' do
    product_category = fast_create(ProductCategory)
    product = fast_create(Product, :product_category_id => product_category.id)
    input = fast_create(Input, :product_id => product.id, :product_category_id => product_category.id)

    assert_not_nil input.name
    assert_equal product_category.name, input.name
  end

  should 'dont have price details when price related fields was not filled' do
    input = Input.new
    assert !input.has_price_details?
  end

  should 'has price details if price_per_unit filled' do
    input = build(Input, :price_per_unit => 10.0)
    assert input.has_price_details?
  end

  should 'has price details if amount_used filled' do
    input = build(Input, :amount_used => 10)
    assert input.has_price_details?
  end

  should 'not have price details if only unit is filled' do
    input = build(Input, :unit => Unit.new)
    assert !input.has_price_details?
  end

  should 'accept price_per_unit in american\'s or brazilian\'s currency format' do
    [
      [12.34, 12.34],
      ["12.34", 12.34],
      ["12,34", 12.34],
      ["12.345.678,90", 12345678.90],
      ["12,345,678.90", 12345678.90],
      ["12.345.678", 12345678.00],
      ["12,345,678", 12345678.00]
    ].each do |input, output|
      new_input = build(Input, :price_per_unit => input)
      assert_equal output, new_input.price_per_unit
    end
  end

  should 'accept amount_used in american\'s or brazilian\'s quantidade format' do
    [
      [12.34, 12.34],
      ["12.34", 12.34],
      ["12,34", 12.34],
      ["12.345.678,90", 12345678.90],
      ["12,345,678.90", 12345678.90],
      ["12.345.678", 12345678.00],
      ["12,345,678", 12345678.00]
    ].each do |input, output|
      new_input = build(Input, :amount_used => input)
      assert_equal output, new_input.amount_used
    end
  end

  should 'display amount used' do
    ent = fast_create(Enterprise, :name => 'test ent 1', :identifier => 'test_ent1')
    product_category = fast_create(ProductCategory, :name => 'Products')
    product = fast_create(Product, :profile_id => ent.id, :product_category_id => product_category.id)

    input = build(Input, :product => product)
    input.amount_used = 10.45
    assert_equal '10.45', input.formatted_amount
  end

  should 'display blank if amount_used is blank or nil or zero' do
    input = Input.new
    assert_equal '', input.formatted_amount
    input.amount_used = ''
    input.save

    assert_equal '', input.formatted_amount
  end

  should 'display only integer value if decimal value is 00' do
    ent = fast_create(Enterprise, :name => 'test ent 1', :identifier => 'test_ent1')
    product_category = fast_create(ProductCategory, :name => 'Products')
    product = fast_create(Product, :profile_id => ent.id, :product_category_id => product_category.id)

    input = build(Input, :product => product)
    input.amount_used = 10.00
    assert_equal '10', input.formatted_amount
  end

  should 'display formatted value' do
    ent = fast_create(Enterprise, :name => 'test ent 1', :identifier => 'test_ent1')
    product_category = fast_create(ProductCategory, :name => 'Products')
    product = fast_create(Product, :profile_id => ent.id, :product_category_id => product_category.id)

    input = build(Input, :product => product)
    input.price_per_unit = 1.45
    assert_equal '1.45', input.formatted_value(:price_per_unit)

    input.price_per_unit = 1.4
    assert_equal '1.40', input.formatted_value(:price_per_unit)

    input.price_per_unit = 1
    assert_equal '1.00', input.formatted_value(:price_per_unit)
  end

  should 'has relation with unit' do
    input = Input.new
    assert_kind_of Unit, input.build_unit
  end

  should 'calculate cost of input' do
    input = build(Input, :amount_used => 10, :price_per_unit => 2.00)
    assert_equal 20.00, input.cost
  end

  should 'cost 0 if amount not defined' do
    input = build(Input, :price_per_unit => 2.00)
    assert_equal 0.00, input.cost
  end

  should 'cost 0 if price_per_unit is not defined' do
    input = build(Input, :amount_used => 10)
    assert_equal 0.00, input.cost
  end

  should 'list inputs relevants to price' do
    product_category = fast_create(ProductCategory)
    product = fast_create(Product, :product_category_id => product_category.id)

    i1 = create(Input, :product => product, :product_category => product_category, :relevant_to_price => true)

    i2 = create(Input, :product => product, :product_category => product_category, :relevant_to_price => false)

    i1.save!
    i2.save!
    assert_includes Input.relevant_to_price, i1
    assert_not_includes Input.relevant_to_price, i2
  end

end
