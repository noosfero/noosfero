require_relative '../test_helper'

class EnvironmentTest < ActiveSupport::TestCase

  should 'has a list of units ordered by position' do
    litre = create(Unit, singular: 'Litre', plural: 'Litres', environment: Environment.default)
    meter = create(Unit, singular: 'Meter', plural: 'Meters', environment: Environment.default)
    kilo  = create(Unit, singular: 'Kilo',  plural: 'Kilo',   environment: Environment.default)
    litre.move_to_bottom
    assert_equal ["Meter", "Kilo", "Litre"], Environment.default.units.map(&:singular)
  end

  should 'have production costs' do
    assert_respond_to Environment.default, :production_costs
  end

  should 'list_all_product_categories' do
    env = fast_create(Environment)
    create(Category, name: 'first category', environment_id: env.id)
    cat = create(Category, name: 'second category', environment_id: env.id)
    create(Category, name: 'child category', environment_id: env.id, parent_id: cat.id)
    cat1 = create(ProductCategory, name: 'first product category', environment_id: env.id)
    cat2 = create(ProductCategory, name: 'second product category', environment_id: env.id)
    subcat = create(ProductCategory, name: 'child product category', environment_id: env.id, parent_id: cat2.id)

    cats = env.product_categories
    assert_equal 3, cats.size
    assert cats.include?(cat1)
    assert cats.include?(cat2)
    assert cats.include?(subcat)
  end

  should 'have products through profiles' do
    product_category = create ProductCategory, name: 'Products', environment_id: Environment.default.id
    env = Environment.default
    e1 = fast_create(Enterprise)
    p1 = e1.products.create!(name: 'test_prod1', product_category: product_category)

    assert_includes env.products, p1
  end

  should 'collect the highlighted products with image through enterprises' do
    env = Environment.default
    e1 = fast_create(Enterprise)
    category = create(ProductCategory)
    p1 = create(Product, :enterprise => e1, :name => 'test_prod1', :product_category_id => category.id)
    products = []
    3.times {|n|
      products.push(create(Product, :name => "product #{n}", :profile_id => e1.id,
        :product_category_id => category.id, :highlighted => true,
        :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') }
      ))
    }
    create(Product, :name => "product 4", :profile_id => e1.id, :product_category_id => category.id, :highlighted => true)
    create(Product, :name => "product 5", :profile_id => e1.id, :product_category_id => category.id, :image_builder => {
        :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
      })
    assert_equal products, env.highlighted_products_with_image
  end

end
