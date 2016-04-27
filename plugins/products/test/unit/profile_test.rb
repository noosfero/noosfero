require_relative '../test_helper'

class ProfileTest < ActiveSupport::TestCase

  def setup
    @product_category = create ProductsPlugin::ProductCategory, name: 'Products'
  end

  should 'list product categories' do
    subcategory = create ProductCategory, name: 'Products subcategory', parent_id: @product_category.id
    ent = fast_create(Enterprise, name: 'test ent', identifier: 'test_ent')
    p = create(Product, name: 'test prod', product_category: subcategory, enterprise: ent)

    assert_equivalent [subcategory], ent.product_categories
  end

  should 'not create a products block for enterprise if environment do not let' do
    env = Environment.default
    env.disable('products_for_enterprises')
    ent = fast_create(Enterprise, name: 'test ent', identifier: 'test_ent')
    assert_not_includes ent.blocks.map(&:class), ProductsBlock
  end

  should 'collect the highlighted products with image' do
    env = Environment.default
    e1 = fast_create(Enterprise)
    p1 = create(Product, name: 'test_prod1', product_category_id: @product_category.id, enterprise: e1)
    products = []
    3.times {|n|
      products.push(create(Product, name: "product #{n}", profile_id: e1.id,
        highlighted: true, product_category_id: @product_category.id,
        image_builder: { uploaded_data: fixture_file_upload('/files/rails.png', 'image/png') }
      ))
    }
    create(Product, name: "product 4", profile_id: e1.id, product_category_id: @product_category.id, highlighted: true)
    create(Product, name: "product 5", profile_id: e1.id, product_category_id: @product_category.id, image_builder: {
      uploaded_data: fixture_file_upload('/files/rails.png', 'image/png')
    })
    assert_equal products, e1.highlighted_products_with_image
  end

  should 'have many inputs through products' do
    enterprise = fast_create(Enterprise)
    product = fast_create(Product, profile_id: enterprise.id, product_category_id: @product_category.id)
    product.inputs << build(Input, product_category: @product_category)
    product.inputs << build(Input, product_category: @product_category)

    assert_equal product.inputs.sort, enterprise.inputs.sort
  end

  should 'have production cost' do
    e = fast_create(Enterprise)
    assert_respond_to e, :production_costs
  end

  should 'remove products when removing enterprise' do
    e = fast_create(Enterprise, name: "My enterprise", identifier: 'myenterprise')
    create(Product, enterprise: e, name: 'One product', product_category: @product_category)
    create(Product, enterprise: e, name: 'Another product', product_category: @product_category)

    assert_difference 'Product.count', -2 do
      e.destroy
    end
  end

end
