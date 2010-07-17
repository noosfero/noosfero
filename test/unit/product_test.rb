require File.dirname(__FILE__) + '/../test_helper'

class ProductTest < ActiveSupport::TestCase

  should 'create product' do
    assert_difference Product, :count do
      p = Product.new(:name => 'test product1')
      assert p.save
    end    
  end

  should 'destroy product' do
    p = Product.create(:name => 'test product2')
    assert_difference Product, :count, -1 do
      p.destroy
    end   
  end

  should 'name be unique' do
    Product.create(:name => 'test product3')
    assert_no_difference Product, :count do
      p = Product.new(:name => 'test product3')
      assert !p.save
    end
  end

  should 'list recent products' do
    enterprise = Enterprise.create!(:name => "My enterprise", :identifier => 'my-enterprise')
    Product.delete_all

    p1 = enterprise.products.create!(:name => 'product 1')
    p2 = enterprise.products.create!(:name => 'product 2')
    p3 = enterprise.products.create!(:name => 'product 3')

    assert_equal [p3, p2, p1], Product.recent
  end

  should 'list recent products with limit' do
    enterprise = Enterprise.create!(:name => "My enterprise", :identifier => 'my-enterprise')
    Product.delete_all

    p1 = enterprise.products.create!(:name => 'product 1')
    p2 = enterprise.products.create!(:name => 'product 2')
    p3 = enterprise.products.create!(:name => 'product 3')
    
    assert_equal [p3, p2], Product.recent(2)
  end

  should 'save image on create product' do
    assert_difference Product, :count do
      p = Product.create!(:name => 'test product1', :image_builder => {
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
    p = Product.new(:name => 'a test product')
    p.expects(:category_full_name).returns('interesting category')
    p.save!

    assert_includes Product.find_by_contents('interesting'), p
  end

  should 'have same lat and lng of its enterprise' do
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_enterprise', :lat => 30.0, :lng => 30.0 )
    prod = ent.products.create!(:name => 'test product')

    prod = Product.find(prod.id)
    assert_equal ent.lat, prod.lat
    assert_equal ent.lng, prod.lng
  end

  should 'update lat and lng of product afer update enterprise' do
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_enterprise', :lat => 30.0, :lng => 30.0 )
    prod = ent.products.create!(:name => 'test product')

    ent.lat = 45.0; ent.lng = 45.0; ent.save!

    prod.reload
   
    assert_in_delta 45.0, prod.lat, 0.0001
    assert_in_delta 45.0, prod.lng, 0.0001
  end

  should 'be searched by radius and distance' do
    prod1 = Product.create!(:name => 'prod test 1', :lat => 30.0, :lng => 30.0)
    prod2 = Product.create!(:name => 'prod test 2', :lat => 45.0, :lng => 45.0)

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
    assert_equal({:controller => 'catalog', :action => 'show', :id => 999}, product.url)
  end

  should 'categorize also with product categorization' do
    cat = ProductCategory.create(:name => 'test cat', :environment => Environment.default)
    ent = Enterprise.create!(:name => 'test ent', :identifier => 'test_ent')
    p = ent.products.create!(:name => 'test product')
    p.product_category = cat
    p.save!

    assert ProductCategorization.find(:first, :conditions => {:product_id => p, :category_id => cat}) 
  end
  
  should 'categorize parent cateogries with product categorization' do
    parent_cat = ProductCategory.create(:name => 'test cat', :environment => Environment.default)
    child_cat = ProductCategory.create(:name => 'test cat', :environment => Environment.default, :parent => parent_cat)
    ent = Enterprise.create!(:name => 'test ent', :identifier => 'test_ent')
    p = ent.products.create!(:name => 'test product')
    p.product_category = child_cat
    p.save!

    assert ProductCategorization.find(:first, :conditions => {:product_id => p, :category_id => parent_cat}) 
    assert ProductCategorization.find(:first, :conditions => {:product_id => p, :category_id => child_cat}) 
  end

  should 'change product categorization when product category changes' do
    cat1 = ProductCategory.create(:name => 'test cat 1', :environment => Environment.default)
    cat2 = ProductCategory.create(:name => 'test cat 2', :environment => Environment.default)
    ent = Enterprise.create!(:name => 'test ent', :identifier => 'test_ent')
    p = ent.products.create!(:name => 'test product', :product_category => cat1)

    p.product_category = cat2
    p.save!

    assert ProductCategorization.find(:first, :conditions => {:product_id => p, :category_id => cat2}), 'must include the new category'
    assert !ProductCategorization.find(:first, :conditions => {:product_id => p, :category_id => cat1}), 'must exclude the old category'
  end

  should 'remove categorization when product category is removed' do
    cat = ProductCategory.create(:name => 'test cat', :environment => Environment.default)
    ent = Enterprise.create!(:name => 'test ent', :identifier => 'test_ent')
    p = ent.products.create!(:name => 'test product', :product_category => cat)

    p.product_category = nil
    p.save!

    assert !ProductCategorization.find(:first, :conditions => {:product_id => p, :category_id => cat}) 
  end

  should 'respond to public? as its enterprise public?' do
    e1 = Enterprise.create!(:name => 'test ent 1', :identifier => 'test_ent1')
    p1 = Product.create!(:name => 'test product 1', :enterprise => e1)

    assert p1.public?

    e1.public_profile = false
    e1.save!

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

  should 'sanitize name before validation' do
    product = Product.new
    product.name = "<h1 Bla </h1>"
    product.valid?

    assert product.errors.invalid?(:name)
  end

  should 'escape malformed html tags' do
    product = Product.new
    product.name = "<h1 Malformed >> html >< tag"
    product.description = "<h1 Malformed</h1>><<<a>> >> html >< tag"
    product.valid?

    assert_no_match /[<>]/, product.name
    assert_no_match /[<>]/, product.description
  end

end
