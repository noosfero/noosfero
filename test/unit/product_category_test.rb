require_relative "../test_helper"

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

  should 'provide a scope based on the enterprise' do
    enterprise = fast_create(Enterprise)
    c1 = ProductCategory.create!(:name => 'test cat 1', :environment => Environment.default)
    c2 = ProductCategory.create!(:name => 'test cat 2', :environment => Environment.default)
    c3 = ProductCategory.create!(:name => 'test cat 3', :environment => Environment.default)
    p1 = Product.new(:name => 'product1', :product_category => c1)
    p1.profile = enterprise
    p1.save!
    p2 = Product.new(:name => 'product2', :product_category => c1)
    p2.profile = enterprise
    p2.save!
    p3 = Product.new(:name => 'product3', :product_category => c2)
    p3.profile = enterprise
    p3.save!

    scope = ProductCategory.by_enterprise(enterprise)

    assert_equal ActiveRecord::Relation, scope.class
    assert_equivalent [c1,c2], scope
  end

  should 'provide a scope based on the environment' do
    alt_environment = fast_create(Environment)
    c1 = ProductCategory.create!(:name => 'test cat 1', :environment => Environment.default)
    c2 = ProductCategory.create!(:name => 'test cat 2', :environment => alt_environment)
    c3 = ProductCategory.create!(:name => 'test cat 3', :environment => Environment.default)

    scope = ProductCategory.by_environment(alt_environment)

    assert_equal ActiveRecord::Relation, scope.class
    assert_equivalent [c2], scope
    assert_equivalent [c1,c3], ProductCategory.by_environment(Environment.default)
  end

  should 'fetch unique categories by level' do
    c1 = ProductCategory.create!(:name => 'test cat 1', :environment => Environment.default)
    c11 = ProductCategory.create!(:name => 'test cat 11', :environment => Environment.default, :parent => c1)
    c12 = ProductCategory.create!(:name => 'test cat 12', :environment => Environment.default, :parent => c1)
    c111 = ProductCategory.create!(:name => 'test cat 111', :environment => Environment.default, :parent => c11)
    c112 = ProductCategory.create!(:name => 'test cat 112', :environment => Environment.default, :parent => c11)

    assert_equivalent ['', 'test-cat-11', 'test-cat-12'], ProductCategory.unique_by_level(2).map(&:filtered_category)
  end

end
