require File.dirname(__FILE__) + '/../test_helper'

class ProductTest < Test::Unit::TestCase

  should 'create product' do
    assert_difference Product, :count do
      p = Product.new(:name => 'test product')
      assert p.save
    end    
  end

  should 'destroy product' do
    p = Product.create(:name => 'test product')
    assert_difference Product, :count, -1 do
      p.destroy
    end   
  end

  should 'name be unique' do
    Product.create(:name => 'test product')
    assert_no_difference Product, :count do
      p = Product.new(:name => 'test product')
      assert !p.save
    end
  end
end
