require File.dirname(__FILE__) + '/../test_helper'

class ProductCategoryTest < Test::Unit::TestCase
  # TODO: please write tests here when ProductCategory has something
  def test_require_same_class_for_children
    c1 = ProductCategory.new(:name => 'Some Product Type', :environment => Environment.default)
    c1.save!

    c2 = Category.new(:name => 'wrong', :environment => Environment.default)
    c1.children << c2

    assert !c2.valid?
    assert c2.errors.invalid?(:type)

    c3 = ProductCategory.new(:name => 'right', :environment => Environment.default)
    c1.children << c3
    assert c3.valid?
    assert !c3.errors.invalid?(:type)
  end

  def test_tree
    c0 = ProductCategory.create!(:name => 'base_cat', :environment => Environment.default)
    assert ! c0.new_record?
    assert_equivalent [c0], c0.tree

    c1 = ProductCategory.create!(:name => 'cat_1', :parent => c0, :environment => Environment.default)
    c0.reload
    assert_equivalent [c1], c1.tree
    assert_equivalent [c0, c1], c0.tree

    c2 = ProductCategory.create!(:name => 'cat_2', :parent => c0, :environment => Environment.default)
    c0.reload; c1.reload;
    assert_equivalent [c0,c1,c2] , c0.tree

    c3 = ProductCategory.create!(:name => 'cat_3', :parent => c2, :environment => Environment.default)
    c0.reload; c1.reload; c2.reload
    assert_equivalent [c0,c1,c2,c3], c0.tree
    assert_equivalent [c2,c3], c2.tree
    
  end

  def test_all_products
    c0 = ProductCategory.create!(:name => 'base_cat', :environment => Environment.default)
    assert_equivalent [], c0.all_products

    p0 = Product.create(:name => 'product1', :product_category => c0)
    c0.reload
    assert_equivalent [p0], c0.all_products

    c1 = ProductCategory.create!(:name => 'cat_1', :parent => c0, :environment => Environment.default)
    p1 = Product.create(:name => 'product2', :product_category => c1)
    c0.reload; c1.reload
    assert_equivalent [p0, p1], c0.all_products
    assert_equivalent [p1], c1.all_products 
  end

  should 'have consumers' do
    c = ProductCategory.create!(:name => 'base_cat', :environment => Environment.default)
    person = create_user('test_user').person
    c.consumers << person
    assert_includes c.consumers, person
  end

end
