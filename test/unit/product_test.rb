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

end
