require File.dirname(__FILE__) + '/../test_helper'

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
    p = fast_create(Product, :name => 'test product1', :product_category_id => @product_category.id, :enterprise_id => @profile.id)

    assert_equal @profile.region, p.region
  end

  should 'create product' do
    assert_difference Product, :count do
      p = Product.new(:name => 'test product1', :product_category => @product_category, :enterprise_id => @profile.id)
      assert p.save
    end
  end

  should 'destroy product' do
    p = fast_create(Product, :name => 'test product2', :product_category_id => @product_category.id)
    assert_difference Product, :count, -1 do
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
    assert_difference Product, :count do
      p = Product.create!(:name => 'test product1', :product_category => @product_category, :image_builder => {
        :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
      }, :enterprise_id => @profile.id)
      assert_equal p.image(true).filename, 'rails.png'
    end
  end

  should 'calculate category full name' do
    cat = mock
    cat.expects(:full_name).returns('A/B/C')

    p = Product.new
    p.stubs(:product_category).returns(cat)
    assert_equal ['A','B','C'], p.category_full_name
  end

  should 'return a nil cateory full name when not categorized' do
    p = Product.new
    p.stubs(:product_category).returns(nil)
    assert_equal nil, p.category_full_name
  end

  should 'be indexed by category full name' do
    TestSolr.enable
    parent_cat = fast_create(ProductCategory, :name => 'Parent')
    prod_cat = fast_create(ProductCategory, :name => 'Category1', :parent_id => parent_cat.id)
    prod_cat2 = fast_create(ProductCategory, :name => 'Category2')
    p = Product.create(:name => 'a test', :product_category => prod_cat, :enterprise_id => @profile.id)
    p2 = Product.create(:name => 'another test', :product_category => prod_cat2, :enterprise_id => @profile.id)

    r = Product.find_by_contents('Parent')[:results].docs
    assert_includes r, p
    assert_not_includes r, p2
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
    product.expects(:enterprise).returns(enterprise)
    assert_equal({:controller => 'manage_products', :action => 'show', :id => 999}, product.url)
  end

  should 'respond to public? as its enterprise public?' do
    e1 = fast_create(Enterprise, :name => 'test ent 1', :identifier => 'test_ent1')
    p1 = fast_create(Product, :name => 'test product 1', :enterprise_id => e1.id, :product_category_id => @product_category.id)

    assert p1.public?

    e1.public_profile = false
    e1.save!; p1.reload;

    assert !p1.public?
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
      product = Product.new(:price => input)
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
      product = Product.new(:discount => input)
      assert_equal output, product.discount
    end
  end

  should 'strip name with malformed HTML when sanitize' do
    product = Product.new(:product_category => @product_category)
    product.name = "<h1 Bla </h1>"
    product.valid?

    assert_equal @product_category.name, product.name
  end

  should 'escape malformed html tags' do
    product = Product.new(:product_category => @product_category)
    product.name = "<h1 Malformed >> html >< tag"
    product.description = "<h1 Malformed</h1>><<<a>> >> html >< tag"
    product.valid?

    assert_no_match /[<>]/, product.name
    assert_no_match /[<>]/, product.description
  end

  should 'use name of category when has no name yet' do
    product = Product.new(:product_category => @product_category, :enterprise_id => @profile.id)
    assert product.valid?
    assert_equal product.name, @product_category.name
  end

  should 'not save without category' do
    product = Product.new(:name => 'A product without category')
    product.valid?
    assert product.errors.invalid?(:product_category_id)
  end

  should 'not save with a invalid category' do
    category = Category.new(:name => 'Region', :environment => Environment.default)
    assert_raise ActiveRecord::AssociationTypeMismatch do
      Product.new(:name => 'Invalid category product', :product_category => category)
    end
  end

  should 'format values to float with 2 decimals' do
    ent = fast_create(Enterprise, :name => 'test ent 1', :identifier => 'test_ent1')
    product = fast_create(Product, :enterprise_id => ent.id, :price => 12.994, :discount => 1.994)

    assert_equal "12.99", product.formatted_value(:price)
    assert_equal "1.99", product.formatted_value(:discount)
  end

  should 'calculate price with discount' do
    ent = fast_create(Enterprise, :name => 'test ent 1', :identifier => 'test_ent1')
    product = fast_create(Product, :enterprise_id => ent.id, :price => 12.994, :discount => 1.994)

    assert_equal 11.00, product.price_with_discount
  end

  should 'calculate price without discount' do
    ent = fast_create(Enterprise, :name => 'test ent 1', :identifier => 'test_ent1')
    product = fast_create(Product, :enterprise_id => ent.id, :price => 12.994, :discount => 0)

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
    product = fast_create(Product, :enterprise_id => ent.id)
    input = fast_create(Input, :product_id => product.id, :product_category_id => @product_category.id)

    assert_equal [input], product.inputs
  end

  should 'destroy inputs when product is removed' do
    ent = fast_create(Enterprise)
    product = fast_create(Product, :enterprise_id => ent.id)
    input = fast_create(Input, :product_id => product.id, :product_category_id => @product_category.id)

    services_category = fast_create(ProductCategory, :name => 'Services')
    input2 = fast_create(Input, :product_id => product.id, :product_category_id => services_category.id)

    assert_difference Input, :count, -2 do
      product.destroy
    end
  end

  should 'test if name is blank' do
    product = Product.new
    assert product.name_is_blank?
  end

  should 'has basic info if filled unit, price or discount' do
    product = Product.new
    assert !product.has_basic_info?

    product = Product.new(:unit => Unit.new)
    assert product.has_basic_info?

    product = Product.new(:price => 1)
    assert product.has_basic_info?

    product = Product.new(:discount => 1)
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
    first = Input.create!(:product => product, :product_category => fast_create(ProductCategory))
    second = Input.create!(:product => product, :product_category => fast_create(ProductCategory))
    third = Input.create!(:product => product, :product_category => fast_create(ProductCategory))

    assert_equal [first, second, third], product.inputs

    product.order_inputs!([second.id, first.id, third.id])

    assert_equal [second, first, third], product.inputs(true)
  end

  should 'format name with unit' do
    product = Product.new(:name => "My product")
    assert_equal "My product", product.name_with_unit
    product.unit = Unit.new(:name => 'litre')
    assert_equal "My product - litre", product.name_with_unit
  end

  should 'have relation with unit' do
    product = Product.new
    assert_kind_of Unit, product.build_unit
  end

  should 'index by schema name when database is postgresql' do
    TestSolr.enable
    uses_postgresql 'schema_one'
    p1 = Product.create!(:name => 'some thing', :product_category => @product_category, :enterprise_id => @profile.id)
    assert_equal [p1], Product.find_by_contents('thing')[:results].docs
    uses_postgresql 'schema_two'
    p2 = Product.create!(:name => 'another thing', :product_category => @product_category, :enterprise_id => @profile.id)
    assert_not_includes Product.find_by_contents('thing')[:results], p1
    assert_includes Product.find_by_contents('thing')[:results], p2
    uses_postgresql 'schema_one'
    assert_includes Product.find_by_contents('thing')[:results], p1
    assert_not_includes Product.find_by_contents('thing')[:results], p2
    uses_sqlite
  end

  should 'not index by schema name when database is not postgresql' do
    TestSolr.enable
    uses_sqlite
    p1 = Product.create!(:name => 'some thing', :product_category => @product_category, :enterprise_id => @profile.id)
    assert_equal [p1], Product.find_by_contents('thing')[:results].docs
    p2 = Product.create!(:name => 'another thing', :product_category => @product_category, :enterprise_id => @profile.id)
    assert_includes Product.find_by_contents('thing')[:results], p1
    assert_includes Product.find_by_contents('thing')[:results], p2
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
    assert !Product.find(product.id).price_described?

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
    assert !product.price_details.empty?

    product.update_price_details([{:production_cost_id => cost.id, :price => 20}, {:production_cost_id => cost2.id, :price => 30}])
    assert_equal 20, product.price_details.find_by_production_cost_id(cost.id).price
    assert_equal 2, Product.find(product.id).price_details.size
  end

  should 'destroy price details if product is removed' do
    product = fast_create(Product)
    cost = fast_create(ProductionCost, :owner_id => Environment.default.id, :owner_type => 'Environment')
    price_detail = product.price_details.create(:production_cost_id => cost.id, :price => 10)

    assert_difference PriceDetail, :count, -1 do
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
    product = fast_create(Product, :enterprise_id => ent.id)
    ent_production_cost = fast_create(ProductionCost, :owner_id => ent.id, :owner_type => 'Profile')
    env_production_cost = fast_create(ProductionCost, :owner_id => ent.environment.id, :owner_type => 'Environment')

    assert_equal [env_production_cost, ent_production_cost], product.available_production_costs
  end

  should 'return all production costs' do
    ent = fast_create(Enterprise)
    product = fast_create(Product, :enterprise_id => ent.id)

    env_production_cost = fast_create(ProductionCost, :owner_id => ent.environment.id, :owner_type => 'Environment')
    ent_production_cost = fast_create(ProductionCost, :owner_id => ent.id, :owner_type => 'Profile')
    product.price_details.create(:production_cost => env_production_cost, :product => product)
    assert_equal [env_production_cost, ent_production_cost], product.available_production_costs
  end

  should 'return total value of production costs' do
    ent = fast_create(Enterprise)
    product = fast_create(Product, :enterprise_id => ent.id)

    env_production_cost = fast_create(ProductionCost, :owner_id => ent.environment.id, :owner_type => 'Environment')
    price_detail = product.price_details.create(:production_cost => env_production_cost, :price => 10)

    input = fast_create(Input, :product_id => product.id, :product_category_id => fast_create(ProductCategory).id, :price_per_unit => 20.0, :amount_used => 2)

    assert_equal price_detail.price + input.cost, product.total_production_cost
  end

  should 'return inputs cost as total value of production costs if has no price details' do
    ent = fast_create(Enterprise)
    product = fast_create(Product, :enterprise_id => ent.id)

    input = fast_create(Input, :product_id => product.id, :product_category_id => fast_create(ProductCategory).id, :price_per_unit => 20.0, :amount_used => 2)

    assert_equal input.cost, product.total_production_cost
  end

  should 'return 0 on total production cost if has no input and price details' do
    product = fast_create(Product)

    assert product.total_production_cost.zero?
  end

  should 'format inputs cost values to float with 2 decimals' do
    ent = fast_create(Enterprise)
    product = fast_create(Product, :enterprise_id => ent.id)
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
    prod = fast_create(Product, :name => 'test product1', :product_category_id => @product_category.id, :enterprise_id => @profile.id)
    assert_equal 0, prod.percentage_from_solidarity_economy.first

    Input.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => false)
    assert_equal 0, prod.percentage_from_solidarity_economy.first

    Input.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    assert_equal 50, prod.percentage_from_solidarity_economy.first

    Input.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => false)
    assert_equal 25, prod.percentage_from_solidarity_economy.first

    prod = fast_create(Product, :name => 'test product1', :product_category_id => @product_category.id, :enterprise_id => @profile.id)
    Input.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    Input.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    Input.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    Input.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => false)
    assert_equal 75, prod.percentage_from_solidarity_economy.first

    prod = fast_create(Product, :name => 'test product', :product_category_id => @product_category.id, :enterprise_id => @profile.id)
    Input.create!(:product_id => prod.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    assert_equal 100, prod.percentage_from_solidarity_economy.first
  end

  should 'delegate region info to enterprise' do
    enterprise = fast_create(Enterprise)
    Enterprise.any_instance.expects(:region)
    Enterprise.any_instance.expects(:region_id)
    product = fast_create(Product, :enterprise_id => enterprise.id)
    product.region
    product.region_id
  end

  should 'delegate environment info to enterprise' do
    enterprise = fast_create(Enterprise)
    Enterprise.any_instance.expects(:environment)
    Enterprise.any_instance.expects(:environment_id)
    product = fast_create(Product, :enterprise_id => enterprise.id)
    product.environment
    product.environment_id
  end

  should 'act as faceted' do
    s = fast_create(State, :acronym => 'XZ')
    c = fast_create(City, :name => 'Tabajara', :parent_id => s.id)
    ent = fast_create(Enterprise, :region_id => c.id)
    cat = fast_create(ProductCategory, :name => 'hardcore')
    p = Product.create!(:name => 'black flag', :enterprise_id => ent.id, :product_category_id => cat.id)
    pq = p.product_qualifiers.create!(:qualifier => fast_create(Qualifier, :name => 'qualifier'),
                                      :certifier => fast_create(Certifier, :name => 'certifier'))
    assert_equal 'Related products', Product.facet_by_id(:f_category)[:label]
    assert_equal ['Tabajara', ', XZ'], Product.facet_by_id(:f_region)[:proc].call(p.send(:f_region))
    assert_equal ['qualifier', ' cert. certifier'], Product.facet_by_id(:f_qualifier)[:proc].call(p.send(:f_qualifier).last)
    assert_equal 'hardcore', p.send(:f_category)
    assert_equal "category_filter:#{cat.id}", Product.facet_category_query.call(cat)
  end

  should 'act as searchable' do
    TestSolr.enable
    s = fast_create(State, :acronym => 'XZ')
    c = fast_create(City, :name => 'Tabajara', :parent_id => s.id)
    ent = fast_create(Enterprise, :region_id => c.id, :name => "Black Sun")
    category = fast_create(ProductCategory, :name => "homemade", :acronym => "hm", :abbreviation => "homey")
    p = Product.create!(:name => 'bananas syrup', :description => 'surrounded by mosquitos', :enterprise_id => ent.id,
                        :product_category_id => category.id)
    qual = Qualifier.create!(:name => 'qualificador', :environment_id => Environment.default.id)
    cert = Certifier.create!(:name => 'certificador', :environment_id => Environment.default.id)
    pq = p.product_qualifiers.create!(:qualifier => qual,	:certifier => cert)
    p.qualifiers.reload
    p.certifiers.reload
    p.save!
    # fields
    assert_includes Product.find_by_contents('bananas')[:results].docs, p
    assert_includes Product.find_by_contents('mosquitos')[:results].docs, p
    assert_includes Product.find_by_contents('homemade')[:results].docs, p
    # filters
    assert_includes Product.find_by_contents('bananas', {}, { :filter_queries => ["public:true"]})[:results].docs, p
    assert_not_includes Product.find_by_contents('bananas', {}, { :filter_queries => ["public:false"]})[:results].docs, p
    assert_includes Product.find_by_contents('bananas', {}, { :filter_queries => ["environment_id:\"#{Environment.default.id}\""]})[:results].docs, p
    # includes
    assert_includes Product.find_by_contents("homemade")[:results].docs, p
    assert_includes Product.find_by_contents(category.slug)[:results].docs, p
    assert_includes Product.find_by_contents("hm")[:results].docs, p
    assert_includes Product.find_by_contents("homey")[:results].docs, p
    assert_includes Product.find_by_contents("Tabajara")[:results].docs, p
    assert_includes Product.find_by_contents("Black Sun")[:results].docs, p
    assert_includes Product.find_by_contents("qualificador")[:results].docs, p
    assert_includes Product.find_by_contents("certificador")[:results].docs, p
  end

  should 'boost name matches' do
    TestSolr.enable
    ent = fast_create(Enterprise)
    cat = fast_create(ProductCategory)
    in_desc = Product.create!(:name => 'something', :enterprise_id => ent.id, :description => 'bananas in the description!',
                              :product_category_id => cat.id)
    in_name = Product.create!(:name => 'bananas in the name!', :enterprise_id => ent.id, :product_category_id => cat.id)
    assert_equal [in_name, in_desc], Product.find_by_contents('bananas')[:results].docs
  end

  should 'reindex enterprise after saving' do
    ent = fast_create(Enterprise)
    cat = fast_create(ProductCategory)
    prod = Product.create!(:name => 'something', :enterprise_id => ent.id, :product_category_id => cat.id)
    Product.expects(:solr_batch_add).with([ent])
    prod.save!
  end

  should 'boost search results that include an image' do
    TestSolr.enable
    product_without_image = Product.create!(:name => 'product without image', :product_category => @product_category,
                                            :enterprise_id => @profile.id)
    product_with_image = Product.create!(:name => 'product with image', :product_category => @product_category,
                                         :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')},
                                         :enterprise_id => @profile.id)
    assert_equal [product_with_image, product_without_image], Product.find_by_contents('product image')[:results].docs
  end

  should 'boost search results that include qualifier' do
    TestSolr.enable
    product_without_q = Product.create!(:name => 'product without qualifier', :product_category => @product_category,
                                        :enterprise_id => @profile.id)
    product_with_q = Product.create!(:name => 'product with qualifier', :product_category => @product_category,
                                     :enterprise_id => @profile.id)
    product_with_q.product_qualifiers.create(:qualifier => fast_create(Qualifier), :certifier => nil)
    product_with_q.save!

    assert_equal [product_with_q, product_without_q], Product.find_by_contents('product qualifier')[:results].docs
  end

  should 'boost search results with open price' do
    TestSolr.enable
    product = Product.create!(:name => 'product 1', :product_category => @product_category, :enterprise_id => @profile.id, :price => 100)
    open_price = Product.new(:name => 'product 2', :product_category => @product_category, :enterprise_id => @profile.id, :price => 100)
    open_price.inputs << Input.new(:product => open_price, :product_category_id => @product_category.id, :amount_used => 10, :price_per_unit => 10)
    open_price.save!

    assert_equal [open_price, product], Product.find_by_contents('product')[:results].docs
  end

  should 'boost search results with solidarity inputs' do
    TestSolr.enable
    product = Product.create!(:name => 'product 1', :product_category => @product_category, :enterprise_id => @profile.id)
    perc_50 = Product.create!(:name => 'product 2', :product_category => @product_category, :enterprise_id => @profile.id)
    Input.create!(:product_id => perc_50.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    Input.create!(:product_id => perc_50.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => false)
    perc_50.save!
    perc_75 = Product.create!(:name => 'product 3', :product_category => @product_category, :enterprise_id => @profile.id)
    Input.create!(:product_id => perc_75.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => false)
    Input.create!(:product_id => perc_75.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    Input.create!(:product_id => perc_75.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    Input.create!(:product_id => perc_75.id, :product_category_id => @product_category.id,
                  :amount_used => 10, :price_per_unit => 10, :is_from_solidarity_economy => true)
    perc_75.save!

    assert_equal [perc_75, perc_50, product], Product.find_by_contents('product')[:results].docs
  end

  should 'boost available search results' do
    TestSolr.enable
    product = Product.create!(:name => 'product 1', :product_category => @product_category, :enterprise_id => @profile.id)
    product.available = false
    product.save!
    product2 = Product.create!(:name => 'product 2', :product_category => @product_category, :enterprise_id => @profile.id)
    product2.available = true
    product2.save!

    assert_equal [product2, product], Product.find_by_contents('product')[:results].docs
  end

  should 'boost search results created updated recently' do
    TestSolr.enable
    product = Product.create!(:name => 'product 1', :product_category => @product_category, :enterprise_id => @profile.id)
    product.update_attribute :created_at, Time.now - 10.day
    product2 = Product.create!(:name => 'product 2', :product_category => @product_category, :enterprise_id => @profile.id)

    assert_equal [product2, product], Product.find_by_contents('product')[:results].docs
  end

  should 'boost search results with description' do
    TestSolr.enable
    product = Product.create!(:name => 'product 1', :product_category => @product_category, :enterprise_id => @profile.id,
                              :description => '')
    product2 = Product.create!(:name => 'product 2', :product_category => @product_category, :enterprise_id => @profile.id,
                               :description => 'a small description')

    assert_equal [product2, product], Product.find_by_contents('product')[:results].docs
  end

  should 'boost if enterprise is enabled' do
    TestSolr.enable
    ent = Enterprise.create!(:name => 'ent', :identifier => 'ent', :enabled => false)
    product = Product.create!(:name => 'product 1', :product_category => @product_category, :enterprise_id => ent.id)
    product2 = Product.create!(:name => 'product 2', :product_category => @product_category, :enterprise_id => @profile.id)

    assert_equal [product2, product], Product.find_by_contents('product')[:results].docs
  end

  should 'combine different boost types' do
    TestSolr.enable
    product = Product.create!(:name => 'product', :product_category => @product_category,	:enterprise_id => @profile.id)
    image_only = Product.create!(:name => 'product with image', :product_category => @product_category,
                                 :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')},
                                 :enterprise_id => @profile.id)
    qual_only = Product.create!(:name => 'product with qualifier', :product_category => @product_category,
                                :enterprise_id => @profile.id)
    img_and_qual = Product.create!(:name => 'product with image and qualifier', :product_category => @product_category,
                                   :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')},
                                   :enterprise_id => @profile.id)
    qual_only.product_qualifiers.create(:qualifier => fast_create(Qualifier), :certifier => nil)
    img_and_qual.product_qualifiers.create(:qualifier => fast_create(Qualifier), :certifier => nil)
    qual_only.save!
    img_and_qual.save!

    assert_equal [img_and_qual, image_only, qual_only, product], Product.find_by_contents('product')[:results].docs
  end

  should 'return more recent products' do
    Product.destroy_all

    prod1 = Product.create!(:name => 'Damaged LP', :enterprise_id => @profile.id, :product_category_id => @product_category.id)
    prod2 = Product.create!(:name => 'Damaged CD', :enterprise_id => @profile.id, :product_category_id => @product_category.id)
    prod3 = Product.create!(:name => 'Damaged DVD', :enterprise_id => @profile.id, :product_category_id => @product_category.id)

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
    p1 = fast_create(Product, :enterprise_id => enterprise.id)
    p2 = fast_create(Product, :enterprise_id => enterprise.id)
    p3 = fast_create(Product, :enterprise_id => enterprise.id)

    products = enterprise.products.from_category(nil)

    assert_includes products, p1
    assert_includes products, p2
    assert_includes products, p3
  end

end
