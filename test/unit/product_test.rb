require File.dirname(__FILE__) + '/../test_helper'

class ProductTest < Test::Unit::TestCase

  def setup
    @product_category = fast_create(ProductCategory, :name => 'Products')
  end

  should 'create product' do
    assert_difference Product, :count do
      p = Product.new(:name => 'test product1', :product_category => @product_category)
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
      })
      assert_equal p.image(true).filename, 'rails.png'
    end    
  end

  should 'calculate catagory full name' do
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
    p = Product.new(:name => 'a test product', :product_category => @product_category)
    p.stubs(:category_full_name).returns('interesting category')
    p.save!

    assert_includes Product.find_by_contents('interesting'), p
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

    prod.reload
   
    assert_in_delta 45.0, prod.lat, 0.0001
    assert_in_delta 45.0, prod.lng, 0.0001
  end

  should 'be searched by radius and distance' do
    prod1 = fast_create(Product, :name => 'prod test 1', :lat => 30.0, :lng => 30.0, :product_category_id => @product_category.id)
    prod2 = fast_create(Product, :name => 'prod test 2', :lat => 45.0, :lng => 45.0, :product_category_id => @product_category.id)

    prods = Product.find(:all, :within => 10, :origin => [30.0, 30.0])

    assert_includes prods, prod1
    assert_not_includes prods, prod2
  end

  should 'provide url' do
    product = Product.new

    enterprise = Enterprise.new
    enterprise.expects(:public_profile_url).returns({})

    product.expects(:id).returns(999)
    product.expects(:enterprise).returns(enterprise)
    assert_equal({:controller => 'manage_products', :action => 'show', :id => 999}, product.url)
  end

  should 'categorize also with product categorization' do
    cat = fast_create(ProductCategory, :name => 'test cat', :environment_id => Environment.default.id)
    ent = fast_create(Enterprise, :name => 'test ent', :identifier => 'test_ent')
    p = ent.products.new(:name => 'test product')
    p.product_category = cat
    p.save!

    assert ProductCategorization.find(:first, :conditions => {:product_id => p, :category_id => cat}) 
  end
  
  should 'categorize parent cateogries with product categorization' do
    parent_cat = fast_create(ProductCategory, :name => 'test cat', :environment_id => Environment.default.id)
    child_cat = fast_create(ProductCategory, :name => 'test cat', :environment_id => Environment.default.id, :parent_id => parent_cat.id)
    ent = fast_create(Enterprise, :name => 'test ent', :identifier => 'test_ent')
    p = ent.products.new(:name => 'test product')
    p.product_category = child_cat
    p.save!

    assert ProductCategorization.find(:first, :conditions => {:product_id => p, :category_id => parent_cat}) 
    assert ProductCategorization.find(:first, :conditions => {:product_id => p, :category_id => child_cat}) 
  end

  should 'change product categorization when product category changes' do
    cat1 = fast_create(ProductCategory, :name => 'test cat 1', :environment_id => Environment.default.id)
    cat2 = fast_create(ProductCategory, :name => 'test cat 2', :environment_id => Environment.default.id)
    ent = fast_create(Enterprise, :name => 'test ent', :identifier => 'test_ent')
    p = ent.products.create!(:name => 'test product', :product_category => cat1)

    p.product_category = cat2
    p.save!

    assert ProductCategorization.find(:first, :conditions => {:product_id => p, :category_id => cat2}), 'must include the new category'
    assert !ProductCategorization.find(:first, :conditions => {:product_id => p, :category_id => cat1}), 'must exclude the old category'
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
    product = Product.new(:product_category => @product_category)
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
    uses_postgresql 'schema_one'
    p1 = Product.create!(:name => 'some thing', :product_category => @product_category)
    assert_equal Product.find_by_contents('thing'), [p1]
    uses_postgresql 'schema_two'
    p2 = Product.create!(:name => 'another thing', :product_category => @product_category)
    assert_not_includes Product.find_by_contents('thing'), p1
    assert_includes Product.find_by_contents('thing'), p2
    uses_postgresql 'schema_one'
    assert_includes Product.find_by_contents('thing'), p1
    assert_not_includes Product.find_by_contents('thing'), p2
    uses_sqlite
  end

  should 'not index by schema name when database is not postgresql' do
    uses_sqlite
    p1 = Product.create!(:name => 'some thing', :product_category => @product_category)
    assert_equal Product.find_by_contents('thing'), [p1]
    p2 = Product.create!(:name => 'another thing', :product_category => @product_category)
    assert_includes Product.find_by_contents('thing'), p1
    assert_includes Product.find_by_contents('thing'), p2
  end

end
