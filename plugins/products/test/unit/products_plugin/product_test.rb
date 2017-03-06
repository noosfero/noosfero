require_relative '../../test_helper'

class ProductsPlugin::ProductTest < ActiveSupport::TestCase

  def setup
    super
    @product_category = create ProductsPlugin::ProductCategory, name: 'Products'
    @profile = create Enterprise
    @product = create ProductsPlugin::Product, product_category: @product_category, profile: @profile
  end

  attr_accessor :product, :profile, :product_category

  should 'validate the presence of enterprise' do
    p = ProductsPlugin::Product.new
    assert_raise ActiveRecord::RecordInvalid do
      p.save!
    end
  end

  should 'return associated enterprise region' do
    @profile.region = create Region, name: 'Salvador'
    @profile.save!

    assert_equal @profile.region, product.region
  end

  should 'display category name if name is nil' do
    product.update name: nil
    assert_equal product_category.name, product.name
  end

  should 'display category name if name is blank' do
    product.update name: ''
    assert_equal product_category.name, product.name
  end

  should 'set nil to name if name is equal to category name' do
    product.expects(:category_name).returns('Software').at_least_once
    product.name = 'Software'
    product.save
    assert_equal 'Software', product.name
    assert_equal nil, product[:name]
  end

  should 'list recent products' do
    enterprise = create(Enterprise, name: "My enterprise", identifier: 'my-enterprise')
    ProductsPlugin::Product.delete_all

    p1 = enterprise.products.create!(name: 'product 1', product_category: @product_category)
    p2 = enterprise.products.create!(name: 'product 2', product_category: @product_category)
    p3 = enterprise.products.create!(name: 'product 3', product_category: @product_category)

    assert_equal [p3, p2, p1], ProductsPlugin::Product.recent
  end

  should 'list recent products with limit' do
    enterprise = create(Enterprise, name: "My enterprise", identifier: 'my-enterprise')
    ProductsPlugin::Product.delete_all

    p1 = enterprise.products.create!(name: 'product 1', product_category: @product_category)
    p2 = enterprise.products.create!(name: 'product 2', product_category: @product_category)
    p3 = enterprise.products.create!(name: 'product 3', product_category: @product_category)

    assert_equal [p3, p2], ProductsPlugin::Product.recent(2)
  end

  should 'save image on create product' do
    assert_difference 'Product.count' do
      p = create(ProductsPlugin::Product, name: 'test product1', profile: profile, product_category: product_category, image_builder: {
        uploaded_data: fixture_file_upload('/files/rails.png', 'image/png')
      }, profile_id: @profile.id)
      assert_equal p.image(true).filename, 'rails.png'
    end
  end

  should 'have same lat and lng of its enterprise' do
    profile.update lat: 30.0, lng: 30.0

    prod = ProductsPlugin::Product.find(product.id)
    assert_equal profile.lat, prod.lat
    assert_equal profile.lng, prod.lng
  end

  should 'provide url' do
    enterprise = Enterprise.new
    enterprise.expects(:public_profile_url).returns({})

    product.expects(:id).returns(999)
    product.expects(:profile).returns(enterprise)
    assert_equal({controller: 'products_plugin/page', action: 'show', id: 999}, product.url)
  end

  should 'respond to public? as its enterprise public?' do
    e1 = create(Enterprise, name: 'test ent 1', identifier: 'test_ent1')
    p1 = create(ProductsPlugin::Product, name: 'test product 1', profile_id: e1.id, product_category_id: @product_category.id)

    assert p1.public?

    e1.public_profile = false
    e1.save!; p1.reload;

    refute p1.public?
  end

  should 'accept prices in american\'s or brazilian\'s currency format' do
    [
      [12.34, 12.34],
      ["12.34", 12.34],
      ["12,34", 12.34],
      ["12.345.678,90", 12345678.90],
      ["12,345,678.90", 12345678.90],
      ["12.345.678", 12345678.00],
      ["12,345,678", 12345678.00]
    ].each do |input, output|
      product.update price: input
      assert_equal output, product.price
    end
  end

  should 'accept discount in american\'s or brazilian\'s currency format' do
    [
      [12.34, 12.34],
      ["12.34", 12.34],
      ["12,34", 12.34],
      ["12.345.678,90", 12345678.90],
      ["12,345,678.90", 12345678.90],
      ["12.345.678", 12345678.00],
      ["12,345,678", 12345678.00]
    ].each do |input, output|
      product.update discount: input
      assert_equal output, product.discount
    end
  end

  should 'strip name with malformed HTML when sanitize' do
    product.name = "<h1 Bla </h1>"
    product.valid?

    assert_equal @product_category.name, product.name
  end

  should 'not save without category' do
    product = build(ProductsPlugin::Product, name: 'A product without category')
    product.valid?
    assert product.errors[:product_category_id.to_s].present?
  end

  should 'not save with a invalid category' do
    category = build(Category, name: 'Region', environment: Environment.default)
    assert_raise ActiveRecord::AssociationTypeMismatch do
      build(ProductsPlugin::Product, name: 'Invalid category product', product_category: category)
    end
  end

  should 'format values to float with 2 decimals' do
    product.update price: 12.994, discount: 1.994

    assert_equal "12.99", product.formatted_value(:price)
    assert_equal "1.99", product.formatted_value(:discount)
  end

  should 'calculate price with discount' do
    product.update price: 12.994, discount: 1.994

    assert_equal 11.00, product.price_with_discount
  end

  should 'calculate price without discount' do
    product.update price: 12.994, discount: 0

    assert_equal product.price, product.price_with_discount
  end

  should 'not accept a discount bigger than the price' do
    refute product.update(price: 10.00, discount: 200.00)
    assert product.errors.include?(:discount)
  end

  should 'not accept a discount and no price' do
    refute product.update(discount: 200.00)
    assert product.errors.include?(:discount)
  end

  should 'have default image' do
    assert_equal '/images/icons-app/product-default-pic-thumb.png', product.default_image
  end

  should 'have inputs' do
    assert_respond_to product, :inputs
  end

  should 'return empty array if has no input' do
    assert product.inputs.empty?
  end

  should 'return product inputs' do
    input = create(ProductsPlugin::Input, product_id: product.id, product_category_id: @product_category.id)

    assert_equal [input], product.inputs
  end

  should 'destroy inputs when product is removed' do
    input = create(ProductsPlugin::Input, product_id: product.id, product_category_id: @product_category.id)

    services_category = create(ProductsPlugin::ProductCategory, name: 'Services')
    input2 = create(ProductsPlugin::Input, product_id: product.id, product_category_id: services_category.id)

    assert_difference 'ProductsPlugin::Input.count', -2 do
      product.destroy
    end
  end

  should 'test if name is blank' do
    assert ProductsPlugin::Product.new.name_is_blank?
  end

  should 'has basic info if filled unit, price or discount' do
    product = ProductsPlugin::Product.new
    refute product.has_basic_info?

    product = build(ProductsPlugin::Product, unit: Unit.new)
    assert product.has_basic_info?

    product = build(ProductsPlugin::Product, price: 1)
    assert product.has_basic_info?

    product = build(ProductsPlugin::Product, discount: 1)
    assert product.has_basic_info?
  end

  should 'destroy all qualifiers when save qualifiers list' do
    product.product_qualifiers.create(qualifier: create(ProductsPlugin::Qualifier), certifier: create(ProductsPlugin::Certifier))
    product.product_qualifiers.create(qualifier: create(ProductsPlugin::Qualifier), certifier: create(ProductsPlugin::Certifier))
    product.product_qualifiers.create(qualifier: create(ProductsPlugin::Qualifier), certifier: create(ProductsPlugin::Certifier))

    assert_equal 3, product.qualifiers.count

    product.qualifiers_list = [[create(ProductsPlugin::Qualifier).id, create(ProductsPlugin::Certifier).id]]

    assert_equal 1, product.qualifiers.count
  end

  should 'save order of inputs' do
    first = create(ProductsPlugin::Input, product: product, product_category: create(ProductsPlugin::ProductCategory))
    second = create(ProductsPlugin::Input, product: product, product_category: create(ProductsPlugin::ProductCategory))
    third = create(ProductsPlugin::Input, product: product, product_category: create(ProductsPlugin::ProductCategory))

    assert_equal [first, second, third], product.inputs

    product.order_inputs!([second.id, first.id, third.id])

    assert_equal [second, first, third], product.inputs(true)
  end

  should 'format name with unit' do
    product = build(ProductsPlugin::Product, name: "My product")
    assert_equal "My product", product.name_with_unit
    product.unit = build(Unit, name: 'litre')
    assert_equal "My product - litre", product.name_with_unit
  end

  should 'have relation with unit' do
    product = ProductsPlugin::Product.new
    assert_kind_of Unit, product.build_unit
  end

  should 'respond to price details' do
    product = ProductsPlugin::Product.new
    assert_respond_to product, :price_details
  end

  should 'return total value of inputs' do
    first = create(ProductsPlugin::Input, product_id: product.id, product_category_id: create(ProductsPlugin::ProductCategory).id, price_per_unit: 20.0, amount_used: 2)
    second = create(ProductsPlugin::Input, product_id: product.id, product_category_id: create(ProductsPlugin::ProductCategory).id, price_per_unit: 10.0, amount_used: 1)

    assert_equal 50.0, product.inputs_cost
  end

  should 'return total value only of inputs relevant to price' do
    first_relevant = create(ProductsPlugin::Input, product_id: product.id, product_category_id: create(ProductsPlugin::ProductCategory).id, price_per_unit: 20.0, amount_used: 2)
    second_relevant = create(ProductsPlugin::Input, product_id: product.id, product_category_id: create(ProductsPlugin::ProductCategory).id, price_per_unit: 10.0, amount_used: 1)
    not_relevant = create(ProductsPlugin::Input, product_id: product.id, product_category_id: create(ProductsPlugin::ProductCategory).id, price_per_unit: 10.0, amount_used: 1, relevant_to_price: false)

    assert_equal 50.0, product.inputs_cost
  end

  should 'return 0 on total value of inputs if has no input' do
    assert product.inputs_cost.zero?
  end

  should 'know if price is described' do
    product.update price: 30.0

    first = create(ProductsPlugin::Input, product_id: product.id, product_category_id: create(ProductsPlugin::ProductCategory).id, price_per_unit: 20.0, amount_used: 1)
    refute Product.find(product.id).price_described?

    second = create(ProductsPlugin::Input, product_id: product.id, product_category_id: create(ProductsPlugin::ProductCategory).id, price_per_unit: 10.0, amount_used: 1)
    assert Product.find(product.id).price_described?
  end

  should 'return false on price_described if price of product is not defined' do
    assert_equal false, product.price_described?
  end

  should 'create price details' do
    cost = create(ProductsPlugin::ProductionCost, owner_id: Environment.default.id, owner_type: 'Environment')
    assert product.price_details.empty?

    product.update_price_details([{production_cost_id: cost.id, price: 10}])
    assert_equal 1, ProductsPlugin::Product.find(product.id).price_details.size
  end

  should 'update price of a cost on price details' do
    cost = create(ProductsPlugin::ProductionCost, owner_id: Environment.default.id, owner_type: 'Environment')
    cost2 = create(ProductsPlugin::ProductionCost, owner_id: Environment.default.id, owner_type: 'Environment')
    price_detail = product.price_details.create(production_cost_id: cost.id, price: 10)
    refute product.price_details.empty?

    product.update_price_details([{production_cost_id: cost.id, price: 20}, {production_cost_id: cost2.id, price: 30}])
    assert_equal 20, product.price_details.find_by(production_cost_id: cost.id).price
    assert_equal 2, Product.find(product.id).price_details.size
  end

  should 'destroy price details if product is removed' do
    cost = create(ProductsPlugin::ProductionCost, owner_id: Environment.default.id, owner_type: 'Environment')
    price_detail = product.price_details.create(production_cost_id: cost.id, price: 10)

    assert_difference 'ProductsPlugin::PriceDetail.count', -1 do
      product.destroy
    end
  end

  should 'have production costs' do
    cost = create(ProductsPlugin::ProductionCost, owner_id: Environment.default.id, owner_type: 'Environment')
    product.price_details.create(production_cost_id: cost.id, price: 10)
    assert_equal [cost], ProductsPlugin::Product.find(product.id).production_costs
  end

  should 'return production costs from enterprise and environment' do
    ent_production_cost = create(ProductsPlugin::ProductionCost, owner_id: profile.id, owner_type: 'Profile')
    env_production_cost = create(ProductsPlugin::ProductionCost, owner_id: profile.environment_id, owner_type: 'Environment')

    assert_equal [env_production_cost, ent_production_cost], product.available_production_costs
  end

  should 'return all production costs' do
    env_production_cost = create(ProductsPlugin::ProductionCost, owner_id: profile.environment_id, owner_type: 'Environment')
    ent_production_cost = create(ProductsPlugin::ProductionCost, owner_id: profile.id, owner_type: 'Profile')
    create ProductsPlugin::PriceDetail, product: product, production_cost: env_production_cost
    assert_equal [env_production_cost, ent_production_cost], product.available_production_costs
  end

  should 'return total value of production costs' do
    env_production_cost = create(ProductsPlugin::ProductionCost, owner_id: profile.environment_id, owner_type: 'Environment')
    price_detail = create(ProductsPlugin::PriceDetail, product: product, production_cost: env_production_cost, price: 10)

    input = create(ProductsPlugin::Input, product_id: product.id, product_category_id: create(ProductsPlugin::ProductCategory).id, price_per_unit: 20.0, amount_used: 2)

    assert_equal price_detail.price + input.cost, product.total_production_cost
  end

  should 'return inputs cost as total value of production costs if has no price details' do
    input = create(ProductsPlugin::Input, product_id: product.id, product_category_id: create(ProductsPlugin::ProductCategory).id, price_per_unit: 20.0, amount_used: 2)

    assert_equal input.cost, product.total_production_cost
  end

  should 'return 0 on total production cost if has no input and price details' do
    assert product.total_production_cost.zero?
  end

  should 'format inputs cost values to float with 2 decimals' do
    first = create ProductsPlugin::Input, product_id: product.id, product_category: create(ProductsPlugin::ProductCategory), price_per_unit: 20.0, amount_used: 2
    second = create ProductsPlugin::Input, product_id: product.id, product_category: create(ProductsPlugin::ProductCategory), price_per_unit: 10.0, amount_used: 1

    assert_equal "50.00", product.formatted_value(:inputs_cost)
  end

  should 'return 0 on price_description_percentage by default' do
    assert_equal 0, ProductsPlugin::Product.new.price_description_percentage
  end

  should 'return 0 on price_description_percentage if price is 0' do
    product.update price: 0

    assert_equal 0, product.price_description_percentage
  end

  should 'return 0 on price_description_percentage if price is not defined' do
    assert_equal 0, product.price_description_percentage
  end

  should 'return 0 on price_description_percentage if total_production_cost is 0' do
    product.update price: 50

    assert_equal 0, product.price_description_percentage
  end

  should 'return solidarity percentage from inputs' do
    prod = create(ProductsPlugin::Product, name: 'test product1', product_category_id: @product_category.id, profile_id: @profile.id)
    assert_equal 0, prod.percentage_from_solidarity_economy.first

    prod.inputs.create!(product_id: prod.id, product_category_id: @product_category.id,
                  amount_used: 10, price_per_unit: 10, is_from_solidarity_economy: false)
    assert_equal 0, prod.percentage_from_solidarity_economy.first

    prod.inputs.create!(product_id: prod.id, product_category_id: @product_category.id,
                  amount_used: 10, price_per_unit: 10, is_from_solidarity_economy: true)
    assert_equal 50, prod.percentage_from_solidarity_economy.first

    prod.inputs.create!(product_id: prod.id, product_category_id: @product_category.id,
                  amount_used: 10, price_per_unit: 10, is_from_solidarity_economy: false)
    assert_equal 25, prod.percentage_from_solidarity_economy.first

    prod = create(ProductsPlugin::Product, name: 'test product2', product_category_id: @product_category.id, profile_id: @profile.id)
    prod.inputs.create!(product_id: prod.id, product_category_id: @product_category.id,
                  amount_used: 10, price_per_unit: 10, is_from_solidarity_economy: true)
    prod.inputs.create!(product_id: prod.id, product_category_id: @product_category.id,
                  amount_used: 10, price_per_unit: 10, is_from_solidarity_economy: true)
    prod.inputs.create!(product_id: prod.id, product_category_id: @product_category.id,
                  amount_used: 10, price_per_unit: 10, is_from_solidarity_economy: true)
    prod.inputs.create!(product_id: prod.id, product_category_id: @product_category.id,
                  amount_used: 10, price_per_unit: 10, is_from_solidarity_economy: false)
    assert_equal 75, prod.percentage_from_solidarity_economy.first

    prod = create(ProductsPlugin::Product, name: 'test product', product_category_id: @product_category.id, profile_id: @profile.id)
    prod.inputs.create!(product_id: prod.id, product_category_id: @product_category.id,
                  amount_used: 10, price_per_unit: 10, is_from_solidarity_economy: true)
    assert_equal 100, prod.percentage_from_solidarity_economy.first
  end

  should 'delegate region info to enterprise' do
    Enterprise.any_instance.expects(:region)
    Enterprise.any_instance.expects(:region_id)
    product.region
    product.region_id
  end

  should 'delegate environment info to enterprise' do
    Enterprise.any_instance.expects(:environment)
    Enterprise.any_instance.expects(:environment_id)
    product.environment
    product.environment_id
  end

  should 'return more recent products' do
    Product.destroy_all

    prod1 = create(ProductsPlugin::Product, name: 'Damaged LP', profile_id: @profile.id, product_category_id: @product_category.id)
    prod2 = create(ProductsPlugin::Product, name: 'Damaged CD', profile_id: @profile.id, product_category_id: @product_category.id)
    prod3 = create(ProductsPlugin::Product, name: 'Damaged DVD', profile_id: @profile.id, product_category_id: @product_category.id)

    prod1.update_attribute :created_at, Time.now-2.days
    prod2.update_attribute :created_at, Time.now-1.days
    prod3.update_attribute :created_at, Time.now

    assert_equal [prod3, prod2, prod1], ProductsPlugin::Product.more_recent
  end

  should 'return products from a category' do
    pc1 = ProductsPlugin::ProductCategory.create!(name: 'PC1', environment: Environment.default)
    pc2 = ProductsPlugin::ProductCategory.create!(name: 'PC2', environment: Environment.default)
    pc3 = ProductsPlugin::ProductCategory.create!(name: 'PC3', environment: Environment.default, parent: pc1)
    p1 = create(ProductsPlugin::Product, profile: profile, product_category: pc1)
    p2 = create(ProductsPlugin::Product, profile: profile, product_category: pc1)
    p3 = create(ProductsPlugin::Product, profile: profile, product_category: pc2)
    p4 = create(ProductsPlugin::Product, profile: profile, product_category: pc3)

    products = ProductsPlugin::Product.from_category(pc1)

    assert_includes products, p1
    assert_includes products, p2
    assert_not_includes products, p3
    assert_includes products, p4
  end

  should 'not crash if nil is passed to from_category' do
    assert_nothing_raised do
      ProductsPlugin::Product.from_category(nil)
    end
  end

  should 'return from_category scope untouched if passed nil' do
    enterprise = create(Enterprise)
    p1 = create(ProductsPlugin::Product, profile_id: enterprise.id, product_category: product_category)
    p2 = create(ProductsPlugin::Product, profile_id: enterprise.id, product_category: product_category)
    p3 = create(ProductsPlugin::Product, profile_id: enterprise.id, product_category: product_category)

    products = enterprise.products.from_category(nil)

    assert_includes products, p1
    assert_includes products, p2
    assert_includes products, p3
  end

  should 'fetch products from organizations that are visible for a user' do
    person = create_user('some-person').person
    admin = create_user('some-admin').person
    env_admin = create_user('env-admin').person
    env = Environment.default

    e1 = create(Enterprise, public_profile: true , visible: true)
    p1 = create(ProductsPlugin::Product, profile_id: e1.id, product_category: product_category)
    e1.affiliate(admin, Profile::Roles.admin(env.id))
    e1.affiliate(person, Profile::Roles.member(env.id))

    e2 = create(Enterprise, public_profile: true , visible: true)
    p2 = create(ProductsPlugin::Product, profile_id: e2.id, product_category: product_category)
    e3 = create(Enterprise, public_profile: false, visible: true)
    p3 = create(ProductsPlugin::Product, profile_id: e3.id, product_category: product_category)

    e4 = create(Enterprise, public_profile: false, visible: true)
    p4 = create(ProductsPlugin::Product, profile_id: e4.id, product_category: product_category)
    e4.affiliate(admin, Profile::Roles.admin(env.id))
    e4.affiliate(person, Profile::Roles.member(env.id))

    e5 = create(Enterprise, public_profile: true, visible: false)
    p5 = create(ProductsPlugin::Product, profile_id: e5.id, product_category: product_category)
    e5.affiliate(admin, Profile::Roles.admin(env.id))
    e5.affiliate(person, Profile::Roles.member(env.id))

    e6 = create(Enterprise, enabled: false, visible: true)
    p6 = create(ProductsPlugin::Product, profile_id: e6.id, product_category: product_category)
    e6.affiliate(admin, Profile::Roles.admin(env.id))

    e7 = create(Enterprise, public_profile: false, visible: false)
    p7 = create(ProductsPlugin::Product, profile_id: e7.id, product_category: product_category)

    Environment.default.add_admin(env_admin)

    products_person    = ProductsPlugin::Product.visible_for_person(person)
    products_admin     = ProductsPlugin::Product.visible_for_person(admin)
    products_env_admin = ProductsPlugin::Product.visible_for_person(env_admin)

    assert_includes     products_person,    p1
    assert_includes     products_admin,     p1
    assert_includes     products_env_admin, p1

    assert_includes     products_person,    p2
    assert_includes     products_env_admin, p2
    assert_not_includes products_person,    p3
    assert_includes     products_env_admin, p3

    assert_includes     products_person,    p4
    assert_includes     products_admin,     p4
    assert_includes     products_env_admin, p4

    assert_not_includes products_person,    p5
    assert_includes     products_admin,     p5
    assert_includes     products_env_admin, p5

    assert_not_includes products_person,    p6
    assert_includes     products_admin,     p6
    assert_includes     products_env_admin, p6

    assert_not_includes products_person,    p7
    assert_includes     products_env_admin, p7
  end

end
