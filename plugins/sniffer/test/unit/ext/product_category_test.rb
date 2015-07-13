require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class ProductCategoryTest < ActiveSupport::TestCase

  def setup
    @category = fast_create(ProductCategory, :name => 'Category 1')
  end

  should 'provide all enterprises that have products with a product category' do
    e1 = fast_create(Enterprise, :identifier => 'ent1' )
    e2 = fast_create(Enterprise, :identifier => 'ent2' )
    e3 = fast_create(Enterprise, :identifier => 'ent3' )

    c2 = fast_create(ProductCategory, :name => 'Category 2')

    # Enteprise 1 and Enteprise 2 have one category 1 products
    fast_create(Product, :product_category_id => @category.id, :profile_id => e1.id )
    fast_create(Product, :product_category_id => @category.id, :profile_id => e2.id )

    # Enteprise 3 has one category 2 products and therefore shouldn't be listed
    fast_create(Product, :product_category_id => c2.id, :profile_id => e3.id )

    assert_equal [e1,e2].sort, @category.sniffer_plugin_enterprises.sort
  end

  should 'provide all enterprises with no duplicates' do
    e1 = fast_create(Enterprise, :identifier => 'ent1' )

    # Enteprise 1 has two category 1 products
    fast_create(Product, :product_category_id => @category.id, :profile_id => e1.id )
    fast_create(Product, :product_category_id => @category.id, :profile_id => e1.id )

    assert_equal [e1], @category.sniffer_plugin_enterprises
  end
end
