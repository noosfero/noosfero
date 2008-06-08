require File.dirname(__FILE__) + '/../test_helper'

class ProductTest < Test::Unit::TestCase

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

  should 'find by initial' do
    p1 = Product.create!(:name => 'a test product')
    p2 = Product.create!(:name => 'A Capitalize Product')
    p3 = Product.create!(:name => 'b-class test product')

    list = Product.find_by_initial('a')

    assert_includes list, p1
    assert_includes list, p2
    assert_not_includes list, p3
  end

  should 'calculate catagory full name' do
    cat = mock
    cat.expects(:full_name).returns('A/B/C')

    p = Product.new
    p.expects(:product_category).returns(cat)
    assert_equal ['A','B','C'], p.category_full_name
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

end
