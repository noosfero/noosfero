require 'test_helper'

class ProfileTest < ActiveSupport::TestCase

  should 'register interest on a product category for a profile' do
    # crate an entreprise
    coop = create(Enterprise,
      :identifier => 'coop', :name => 'A Cooperative', :lat => 0, :lng => 0
    )
    # create categories
    c1 = create(ProductCategory, :name => 'Category 1')
    c2 = create(ProductCategory, :name => 'Category 2')
    # get the extended sniffer profile for the enterprise:
    coop.sniffer_interested_product_category_string_ids = "#{c1.id},#{c2.id}"
    coop.enabled = true
    coop.save!

    categories = coop.sniffer_interested_product_categories
    assert_equal 2, categories.length
    assert_equal 'Category 1', categories[0].name
    assert_equal 'Category 2', categories[1].name
  end

  should 'find suppliers and consumers products' do
    # Enterprises:
    e1 = fast_create(Enterprise, :identifier => 'ent1' )
    e2 = fast_create(Enterprise, :identifier => 'ent2' )
    e3 = fast_create(Enterprise, :identifier => 'ent3' )
    # Categories:
    c1 = fast_create(ProductCategory, :name => 'Category 1')
    c2 = fast_create(ProductCategory, :name => 'Category 2')
    c3 = fast_create(ProductCategory, :name => 'Category 3')
    c4 = fast_create(ProductCategory, :name => 'Category 4') # not used by products
    # Products (for enterprise 1):
    p1 = fast_create(Product, :product_category_id => c1.id, :profile_id => e1.id )
    p2 = fast_create(Product, :product_category_id => c2.id, :profile_id => e1.id )
    # Products (for enterprise 2):
    p3 = fast_create(Product, :product_category_id => c3.id, :profile_id => e2.id )
    p3.inputs.build.product_category = c1 # p3 uses p1 as input on its production
    p3.save!
    # Products (for enterprise 3):
    p4 = fast_create(Product, :product_category_id => c3.id, :profile_id => e3.id )
    p5 = fast_create(Product, :product_category_id => c3.id, :profile_id => e3.id )
    p4.inputs.build.product_category = c1 # p4 uses p1 as input on its production
    p5.inputs.build.product_category = c1 # as does p5
    p4.save!
    p5.save!

    # register e2 interest for 'Category 2' use by p2
    e2.sniffer_interested_product_category_string_ids = "#{c2.id},#{c4.id}"
    e2.enabled = true
    e2.save!

    assert_equal [p1.id, p1.id, p2.id],
      e1.sniffer_consumers_products.sort_by(&:id).map(&:id)

    # since they have interest in the same product, e2 and e3 position
    # may vary here, but the last enterprise should be e2
    assert_equivalent [e2.id, e3.id],
      e1.sniffer_consumers_products.sort_by(&:id).map{|p| p[:consumer_profile_id].to_i}.first(2)
    assert_equal e2.id,
      e1.sniffer_consumers_products.sort_by(&:id).map{|p| p[:consumer_profile_id].to_i}.last

    assert_equal [p1.id, p2.id],
      e2.sniffer_suppliers_products.sort_by(&:id).map(&:id)
    assert_equal [], e2.sniffer_consumers_products
  end

  should 'not search for suppliers and consumers on disabled enterprises' do
    # Enterprises:
    e1 = fast_create(Enterprise, :identifier => 'ent1' )
    e2 = fast_create(Enterprise, :identifier => 'ent2' )
    # Categories:
    c1 = fast_create(ProductCategory, :name => 'Category 1')
    c2 = fast_create(ProductCategory, :name => 'Category 2')
    # Products (for enterprise 1):
    p1 = fast_create(Product, :product_category_id => c1.id, :profile_id => e1.id )

    # Products (for enterprise 2):
    p2 = fast_create(Product, :product_category_id => c2.id, :profile_id => e2.id )
    p2.inputs.build.product_category = c1
    p2.save!

    # register e2 interest for 'Category 1' used by p1
    e2.sniffer_interested_product_category_string_ids = "#{c1.id}"
    e2.enabled = true
    e2.save!

    # should not find anything for disabled enterprise
    e1.enabled = false
    e1.save!
    assert_equal [], e2.sniffer_consumers_products
    assert_equal [], e2.sniffer_suppliers_products
  end

end
