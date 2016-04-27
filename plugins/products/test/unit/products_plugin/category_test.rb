require_relative '../../test_helper'

class ProductsPlugin::ProductCategoryTest < ActiveSupport::TestCase

  def setup
    @env = Environment.default
  end

  should 'should paginate recent-like methods' do
    c = @env.product_categories.create!(name: 'my category')
    assert c.recent_products.respond_to? 'total_entries'
  end

  should 'list recent products' do
    product_category = create ProductCategory, name: 'Products', environment_id: Environment.default.id
    ent1 = fast_create(Enterprise, identifier: 'enterprise_1', name: 'Enterprise one')
    ent2 = fast_create(Enterprise, identifier: 'enterprise_2', name: 'Enterprise one')
    prod1 = ent1.products.create!(name: 'test_prod1', product_category: product_category)
    prod2 = ent2.products.create!(name: 'test_prod2', product_category: product_category)
    assert_equal [prod2, prod1], product_category.recent_products
  end

  should 'have products through enterprises' do
    product_category = create ProductCategory, name: 'Products', environment_id: Environment.default.id
    ent1 = fast_create(Enterprise, identifier: 'enterprise_1', name: 'Enterprise one')
    ent2 = fast_create(Enterprise, identifier: 'enterprise_2', name: 'Enterprise one')
    prod1 = ent1.products.create!(name: 'test_prod1', product_category: product_category)
    prod2 = ent2.products.create!(name: 'test_prod2', product_category: product_category)
    assert_includes product_category.products, prod1
    assert_includes product_category.products, prod2
  end

  should 'accept_products is true by default' do
    assert Category.new.accept_products?
  end

end
