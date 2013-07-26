require File.dirname(__FILE__) + '/../test_helper'

class ProductCategoryTest < ActiveSupport::TestCase

  def test_all_products
    c0 = Environment.default.product_categories.create!(:name => 'base_cat')
    assert_equivalent [], c0.all_products

    profile = fast_create(Enterprise)
    p0 = profile.products.create(:name => 'product1', :product_category => c0)
    c0.reload
    assert_equivalent [p0], c0.all_products

    c1 = Environment.default.product_categories.create!(:name => 'cat_1', :parent => c0)
    p1 = profile.products.create(:name => 'product2', :product_category => c1)
    c0.reload; c1.reload
    assert_equivalent [p0, p1], c0.all_products
    assert_equivalent [p1], c1.all_products
  end

  should 'return top level product categories for environment when no parent product category specified' do
    env1 = Environment.create!(:name => 'test env 1')
    env2 = Environment.create!(:name => 'test env 2')

    c1 = env1.product_categories.create!(:name => 'test cat 1')
    c2 = env2.product_categories.create!(:name => 'test cat 2')

    assert_equal [c1], ProductCategory.menu_categories(nil, env1)
  end

  should 'return children of parent category' do
    c1 = Environment.default.product_categories.create!(:name => 'test cat 1')
    c11 = Environment.default.product_categories.create!(:name => 'test cat 11', :parent => c1)
    c2 = Environment.default.product_categories.create!(:name => 'test cat 2')

    assert_equal [c11], ProductCategory.menu_categories(c1, nil)
  end

end
