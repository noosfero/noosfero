require_relative "../test_helper"

class ProductTest < ActiveSupport::TestCase

  def setup
    super
    @product_category = fast_create(ProductCategory, :name => 'Products')
    @profile = fast_create(Enterprise)
  end

  should 'validate the presence of enterprise' do
    p = Product.new
    assert_raise ActiveRecord::RecordInvalid do
      p.save!
    end
  end

  should 'return associated enterprise region' do
    @profile.region = fast_create Region, :name => 'Salvador'
    @profile.save!
    p = fast_create(Product, :name => 'test product1', :product_category_id => @product_category.id, :profile_id => @profile.id)

    assert_equal @profile.region, p.region
  end

  should 'create product' do
    assert_difference 'Product.count' do
      p = build(Product, :name => 'test product1', :product_category => @product_category, :profile_id => @profile.id)
      assert p.save
    end
  end

  should 'destroy product' do
    p = fast_create(Product, :name => 'test product2', :product_category_id => @product_category.id)
    assert_difference 'Product.count', -1 do
      p.destroy
    end
  end

  should 'display category name if name is nil' do
    p = fast_create(Product, :name => nil)
    p.expects(:category_name).returns('Software')
    assert_equal 'Software', p.name
  end

  should 'display category name if name is blank' do
    p = fast_create(Product, :name => '')
    p.expects(:category_name).returns('Software')
    assert_equal 'Software', p.name
  end

  should 'set nil to name if name is equal to category name' do
    p = fast_create(Product)
    p.expects(:category_name).returns('Software').at_least_once
    p.name = 'Software'
    p.save
    assert_equal 'Software', p.name
    assert_equal nil, p[:name]
  end

  should 'list recent products' do
    enterprise = fast_create(Enterprise, :name => "My enterprise", :identifier => 'my-enterprise')
    Product.delete_all

    p1 = enterprise.products.create!(:name => 'product 1', :product_category => @product_category)
    p2 = enterprise.products.create!(:name => 'product 2', :product_category => @product_category)
    p3 = enterprise.products.create!(:name => 'product 3', :product_category => @product_category)

    assert_equal [p3, p2, p1], Product.recent
  end

  should 'list recent products with limit' do
    enterprise = fast_create(Enterprise, :name => "My enterprise", :identifier => 'my-enterprise')
    Product.delete_all

    p1 = enterprise.products.create!(:name => 'product 1', :product_category => @product_category)
    p2 = enterprise.products.create!(:name => 'product 2', :product_category => @product_category)
    p3 = enterprise.products.create!(:name => 'product 3', :product_category => @product_category)

    assert_equal [p3, p2], Product.recent(2)
  end

  should 'save image on create product' do
    assert_difference 'Product.count' do
      p = create(Product, :name => 'test product1', :product_category => @product_category, :image_builder => {
        :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
      }, :profile_id => @profile.id)
      assert_equal p.image(true).filename, 'rails.png'
    end
  end

  should 'have same lat and lng of its enterprise' do
    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_enterprise', :lat => 30.0, :lng => 30.0)
    prod = ent.products.create!(:name => 'test product', :product_category => @product_category)

    prod = Product.find(prod.id)
    assert_equal ent.lat, prod.lat
    assert_equal ent.lng, prod.lng
  end

  should 'update lat and lng of product afer update enterprise' do
    ent = fast_create(Enterprise, :name => 'test enterprise', :identifier => 'test_enterprise', :lat => 30.0, :lng => 30.0)
    prod = ent.products.create!(:name => 'test product', :product_category => @product_category)

    ent.lat = 45.0; ent.lng = 45.0; ent.save!
    process_delayed_job_queue
    prod.reload

    assert_in_delta 45.0, prod.lat, 0.0001
    assert_in_delta 45.0, prod.lng, 0.0001
  end

  should 'provide url' do
    product = Product.new

    enterprise = Enterprise.new
    enterprise.expects(:public_profile_url).returns({})

    product.expects(:id).returns(999)
    product.expects(:profile).returns(enterprise)
    assert_equal({:controller => 'manage_products', :action => 'show', :id => 999}, product.url)
  end

  should 'respond to public? as its enterprise public?' do
    e1 = fast_create(Enterprise, :name => 'test ent 1', :identifier => 'test_ent1')
    p1 = fast_create(Product, :name => 'test product 1', :profile_id => e1.id, :product_category_id => @product_category.id)

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
      product = build(Product, :price => input)
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
      product = build(Product, :discount => input)
      assert_equal output, product.discount
    end
  end

  should 'strip name with malformed HTML when sanitize' do
    product = build(Product, :product_category => @product_category)
    product.name = "<h1 Bla </h1>"
    product.valid?

    assert_equal @product_category.name, product.name
  end

  should 'use name of category when has no name yet' do
    product = Product.new
    product.product_category = @product_category
    product.profile = @profile
    assert product.valid?
    assert_equal @product_category.name, product.name
  end

  should 'not save without category' do
    product = build(Product, :name => 'A product without category')
    product.valid?
    assert product.errors[:product_category_id.to_s].present?
  end

  should 'not save with a invalid category' do
    category = build(Category, :name => 'Region', :environment => Environment.default)
    assert_raise ActiveRecord::AssociationTypeMismatch do
      build(Product, :name => 'Invalid category product', :product_category => category)
    end
  end

  should 'format values to float with 2 decimals' do
    ent = fast_create(Enterprise, :name => 'test ent 1', :identifier => 'test_ent1')
    product = fast_create(Product, :profile_id => ent.id, :price => 12.994, :discount => 1.994)

    assert_equal "12.99", product.formatted_value(:price)
    assert_equal "1.99", product.formatted_value(:discount)
  end

  should 'calculate price with discount' do
    ent = fast_create(Enterprise, :name => 'test ent 1', :identifier => 'test_ent1')
    product = fast_create(Product, :profile_id => ent.id, :price => 12.994, :discount => 1.994)

    assert_equal 11.00, product.price_with_discount
  end

  should 'calculate price without discount' do
    ent = fast_create(Enterprise, :name => 'test ent 1', :identifier => 'test_ent1')
    product = fast_create(Product, :profile_id => ent.id, :price => 12.994, :discount => 0)

    assert_equal product.price, product.price_with_discount
  end

  should 'have default image' do
    product = Product.new
    assert_equal '/images/icons-app/product-default-pic-thumb.png', product.default_image
  end

  should 'have inputs' do
    product = Product.new
    assert_respond_to product, :inputs
  end

  should 'return empty array if has no input' do
    product = Product.new
    assert product.inputs.empty?
  end

  should 'return product inputs' do
    ent = fast_create(Enterprise)
    product = fast_create(Product, :profile_id => ent.id)
    input = fast_create(Input, :product_id => product.id, :product_category_id => @product_category.id)

    assert_equal [input], product.inputs
  end

  should 'destroy inputs when product is removed' do
    ent = fast_create(Enterprise)
    product = fast_create(Product, :profile_id => ent.id)
    input = fast_create(Input, :product_id => product.id, :product_category_id => @product_category.id)

    services_category = fast_create(ProductCategory, :name => 'Services')
    input2 = fast_create(Input, :product_id => product.id, :product_category_id => services_category.id)

    assert_difference 'Input.count', -2 do
      product.destroy
    end
  end

  should 'test if name is blank' do
    product = Product.new
    assert product.name_is_blank?
  end

  should 'has basic info if filled unit, price or discount' do
    product = Product.new
    refute product.has_basic_info?

    product = build(Product, :unit => Unit.new)
    assert product.has_basic_info?

    product = build(Product, :price => 1)
    assert product.has_basic_info?

    product = build(Product, :discount => 1)
    assert product.has_basic_info?
  end

  should 'destroy all qualifiers when save qualifiers list' do
    product = fast_create(Product)
    product.product_qualifiers.create(:qualifier => fast_create(Qualifier), :certifier => fast_create(Certifier))
    product.product_qualifiers.create(:qualifier => fast_create(Qualifier), :certifier => fast_create(Certifier))
    product.product_qualifiers.create(:qualifier => fast_create(Qualifier), :certifier => fast_create(Certifier))

    assert_equal 3, product.qualifiers.count

    product.qualifiers_list = [[fast_create(Qualifier).id, fast_create(Certifier).id]]

    assert_equal 1, product.qualifiers.count
  end

  should 'save order of inputs' do
    product = fast_create(Product)
    first = create(Input, :product => product, :product_category => fast_create(ProductCategory))
    second = create(Input, :product => product, :product_category => fast_create(ProductCategory))
    third = create(Input, :product => product, :product_category => fast_create(ProductCategory))

    assert_equal [first, second, third], product.inputs

    product.order_inputs!([second.id, first.id, third.id])

    assert_equal [second, first, third], product.inputs(true)
  end

  should 'format name with unit' do
    product = build(Product, :name => "My product")
    assert_equal "My product", product.name_with_unit
    product.unit = build(Unit, :name => 'litre')
    assert_equal "My product - litre", product.name_with_unit
  end

  should 'have relation with unit' do
    product = Product.new
    assert_kind_of Unit, product.build_unit
  end

  should 'respond to price details' do
    product = Product.new
    assert_respond_to product, :price_details
  end

  should 'return total value of inputs' do
    product = fast_create(Product)
    first = fast_create(Input, :product_id => product.id, :product_category_id => fast_create(ProductCategory).id, :price_per_unit => 20.0, :amount_used => 2)
    second = fast_create(Input, :product_id => product.id, :product_category_id => fast_create(ProductCategory).id, :price_per_unit => 10.0, :amount_used => 1)

    assert_equal 50.0, product.inputs_cost
  end

  should 'return total value only of inputs relevant to price' do
    product = fast_create(Product)
    first_relevant = fast_create(Input, :product_id => product.id, :product_category_id => fast_create(ProductCategory).id, :price_per_unit => 20.0, :amount_used => 2)
    second_relevant = fast_create(Input, :product_id => product.id, :product_category_id => fast_create(ProductCategory).id, :price_per_unit => 10.0, :amount_used => 1)
    not_relevant = fast_create(Input, :product_id => product.id, :product_category_id => fast_create(ProductCategory).id, :price_per_unit => 10.0, :amount_used => 1, :relevant_to_price => false)

    assert_equal 50.0, product.inputs_cost
  end

  should 'return 0 on total value of inputs if has no input' do
    product = fast_create(Product)

    assert product.inputs_cost.zero?
  end

  should 'know if price is described' do
    product = fast_create(Product, :price => 30.0)

    first = fast_create(Input, :product_id => product.id, :product_category_id => fast_create(ProductCategory).id, :price_per_unit => 20.0, :amount_used => 1)
    refute Product.find(product.id).price_described?

    second = fast_create(Input, :product_id => product.id, :product_category_id => fast_create(ProductCategory).id, :price_per_unit => 10.0, :amount_used => 1)
    assert Product.find(product.id).price_described?
  end

  should 'return false on price_described if price of product is not defined' do
    product = fast_create(Product)

    assert_equal false, product.price_described?
  end

  should 'create price details' do
    product = fast_create(Product)
    cost = fast_create(ProductionCost, :owner_id => Environment.default.id, :owner_type => 'Environment')
    assert product.price_details.empty?

    product.update_price_details([{:production_cost_id => cost.id, :price => 10}])
    assert_equal 1, Product.find(product.id).price_details.size
  end

  should 'update price of a cost on price details' do
    product = fast_create(Product)
    cost = fast_create(ProductionCost, :owner_id => Environment.default.id, :owner_type => 'Environment')
    cost2 = fast_create(ProductionCost, :owner_id => Environment.default.id, :owner_type => 'Environment')
    price_detail = product.price_details.create(:production_cost_id => cost.id, :price => 10)
    refute product.price_details.empty?

    product.update_price_details([{:production_cost_id => cost.id, :price => 20}, {:production_cost_id => cost2.id, :price => 30}])
    assert_equal 20, product.price_details.find_by_production_cost_id(cost.id).price
    assert_equal 2, Product.find(product.id).price_details.size
  end

  should 'destroy price details if product is removed' do
    product = fast_create(Product)
    cost = fast_create(ProductionCost, :owner_id => Environment.default.id, :owner_type => 'Environment')
    price_detail = product.price_details.create(:production_cost_id => cost.id, :price => 10)

    assert_difference 'PriceDetail.count', -1 do
      product.destroy
    end
  end

  should 'have production costs' do
    product = fast_create(Product)
    cost = fast_create(ProductionCost, :owner_id => Environment.default.id, :owner_type => 'Environment')
    product.price_details.create(:production_cost_id => cost.id, :price => 10)
    assert_equal [cost], Product.find(product.id).production_costs
  end

  should 'return production costs from enterprise and environment' do
    ent = fast_create(Enterprise)
    product = fast_create(Product, :profile_id => ent.id)
    ent_production_cost = fast_create(ProductionCost, :owner_id => ent.id, :owner_type => 'Profile')
    env_production_cost = fast_create(ProductionCost, :owner_id => ent.environment.id, :owner_type => 'Environment')

    assert_equal [env_production_cost, ent_production_cost], product.available_production_costs
  end

  should 'return all production costs' do
    ent = fast_create(Enterprise)
    product = fast_create(Product, :profile_id => ent.id)

    env_production_cost = fast_create(ProductionCost, :owner_id => ent.environment.id, :owner_type => 'Environment')
    ent_production_cost = fast_create(ProductionCost, :owner_id => ent.id, :owner_type => 'Profile')
    create(PriceDetail, :product => product, :production_cost => env_production_cost, :product => product)
    assert_equal [env_production_cost, ent_production_cost], product.available_production_costs
  end

  should 'return total value of production costs' do
    ent = fast_create(Enterprise)
    product = fast_create(Product, :profile_id => ent.id)

    env_production_cost = fast_create(ProductionCost, :owner_id => ent.environment.id, :owner_type => 'Environment')
    price_detail = create(PriceDetail, :product => product, :production_cost => env_production_cost, :price => 10)

    input = fast_create(Input, :product_id => product.id, :product_category_id => fast_create(ProductCategory).id, :price_per_unit => 20.0, :amount_used => 2)

    assert_equal price_detail.price + input.cost, product.total_production_cost
  end

  should 'return inputs cost as total value of production costs if has no price details' do
    ent = fast_create(Enterprise)
    product = fast_create(Product, :profile_id => ent.id)

    input = fast_create(Input, :product_id => product.id, :product_category_id => fast_create(ProductCategory).id, :price_per_unit => 20.0, :amount_used => 2)

    assert_equal input.cost, product.total_production_cost
  end

  should 'return 0 on total production cost if has no input and price details' do
    product = fast_create(Product)

    assert product.total_production_cost.zero?
  end

  should 'format inputs cost values to float with 2 decimals' do
    ent = fast_create(Enterprise)
    product = fast_create(Product, :profile_id => ent.id)
    first = fast_create(Input, :product_id => product.id, :product_category_id => fast_create(ProductCategory).id, :price_per_unit => 20.0, :amount_used => 2)
    second = fast_create(Input, :product_id => product.id, :product_category_id => fast_create(ProductCategory).id, :price_per_unit => 10.0, :amount_used => 1)

    assert_equal "50.00", product.formatted_value(:inputs_cost)
  end

  should 'return 0 on price_description_percentage by default' do
    assert_equal 0, Product.new.price_description_percentage
  end

  should 'return 0 on price_description_percentage if price is 0' do
    product = fast_create(Product, :price => 0)

    assert_equal 0, product.price_description_percentage
  end

  should 'return 0 on price_description_percentage if price is not defined' do
    product = fast_create(Product)

    assert_equal 0, product.price_description_percentage
  end

  should 'return 0 on price_description_percentage if total_production_cost is 0' do
    product = fast_create(Product, :price => 50)

    assert_equal 0, product.price_description_percentage
  end

  should 'return solidarity percentage from inputs' do
    prod = fast_create(Product, :name => 'test product1', :product_category_id => @product_category.id, :profile_id => @profile.id)
    assert_equal 0, prod.percentage_from_solidarity_economy.first

    prod.inputs.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => false)
    assert_equal 0, prod.percentage_from_solidarity_economy.first

    prod.inputs.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    assert_equal 50, prod.percentage_from_solidarity_economy.first

    prod.inputs.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => false)
    assert_equal 25, prod.percentage_from_solidarity_economy.first

    prod = fast_create(Product, :name => 'test product1', :product_category_id => @product_category.id, :profile_id => @profile.id)
    prod.inputs.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    prod.inputs.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    prod.inputs.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    prod.inputs.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => false)
    assert_equal 75, prod.percentage_from_solidarity_economy.first

    prod = fast_create(Product, :name => 'test product', :product_category_id => @product_category.id, :profile_id => @profile.id)
    prod.inputs.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    assert_equal 100, prod.percentage_from_solidarity_economy.first
  end

  should 'delegate region info to enterprise' do
    enterprise = fast_create(Enterprise)
    Enterprise.any_instance.expects(:region)
    Enterprise.any_instance.expects(:region_id)
    product = fast_create(Product, :profile_id => enterprise.id)
    product.region
    product.region_id
  end

  should 'delegate environment info to enterprise' do
    enterprise = fast_create(Enterprise)
    Enterprise.any_instance.expects(:environment)
    Enterprise.any_instance.expects(:environment_id)
    product = fast_create(Product, :profile_id => enterprise.id)
    product.environment
    product.environment_id
  end

  should 'return more recent products' do
    Product.destroy_all

    prod1 = create(Product, :name => 'Damaged LP', :profile_id => @profile.id, :product_category_id => @product_category.id)
    prod2 = create(Product, :name => 'Damaged CD', :profile_id => @profile.id, :product_category_id => @product_category.id)
    prod3 = create(Product, :name => 'Damaged DVD', :profile_id => @profile.id, :product_category_id => @product_category.id)

    prod1.update_attribute :created_at, Time.now-2.days
    prod2.update_attribute :created_at, Time.now-1.days
    prod3.update_attribute :created_at, Time.now

    assert_equal [prod3, prod2, prod1], Product.more_recent
  end

  should 'return products from a category' do
    pc1 = ProductCategory.create!(:name => 'PC1', :environment => Environment.default)
    pc2 = ProductCategory.create!(:name => 'PC2', :environment => Environment.default)
    pc3 = ProductCategory.create!(:name => 'PC3', :environment => Environment.default, :parent => pc1)
    p1 = fast_create(Product, :product_category_id => pc1)
    p2 = fast_create(Product, :product_category_id => pc1)
    p3 = fast_create(Product, :product_category_id => pc2)
    p4 = fast_create(Product, :product_category_id => pc3)

    products = Product.from_category(pc1)

    assert_includes products, p1
    assert_includes products, p2
    assert_not_includes products, p3
    assert_includes products, p4
  end

  should 'not crash if nil is passed to from_category' do
    assert_nothing_raised do
      Product.from_category(nil)
    end
  end

  should 'return from_category scope untouched if passed nil' do
    enterprise = fast_create(Enterprise)
    p1 = fast_create(Product, :profile_id => enterprise.id)
    p2 = fast_create(Product, :profile_id => enterprise.id)
    p3 = fast_create(Product, :profile_id => enterprise.id)

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

    e1 = fast_create(Enterprise, :public_profile => true , :visible => true)
    p1 = fast_create(Product, :profile_id => e1.id)
    e1.affiliate(admin, Profile::Roles.admin(env.id))
    e1.affiliate(person, Profile::Roles.member(env.id))

    e2 = fast_create(Enterprise, :public_profile => true , :visible => true)
    p2 = fast_create(Product, :profile_id => e2.id)
    e3 = fast_create(Enterprise, :public_profile => false, :visible => true)
    p3 = fast_create(Product, :profile_id => e3.id)

    e4 = fast_create(Enterprise, :public_profile => false, :visible => true)
    p4 = fast_create(Product, :profile_id => e4.id)
    e4.affiliate(admin, Profile::Roles.admin(env.id))
    e4.affiliate(person, Profile::Roles.member(env.id))

    e5 = fast_create(Enterprise, :public_profile => true, :visible => false)
    p5 = fast_create(Product, :profile_id => e5.id)
    e5.affiliate(admin, Profile::Roles.admin(env.id))
    e5.affiliate(person, Profile::Roles.member(env.id))

    e6 = fast_create(Enterprise, :enabled => false, :visible => true)
    p6 = fast_create(Product, :profile_id => e6.id)
    e6.affiliate(admin, Profile::Roles.admin(env.id))

    e7 = fast_create(Enterprise, :public_profile => false, :visible => false)
    p7 = fast_create(Product, :profile_id => e7.id)

    Environment.default.add_admin(env_admin)

    products_person    = Product.visible_for_person(person)
    products_admin     = Product.visible_for_person(admin)
    products_env_admin = Product.visible_for_person(env_admin)

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
