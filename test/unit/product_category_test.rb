require File.dirname(__FILE__) + '/../test_helper'

class ProductCategoryTest < Test::Unit::TestCase
  # TODO: please write tests here when ProductCategory has something
  def test_require_same_class_for_children
    c1 = ProductCategory.new(:name => 'Some Product Type', :environment_id => 1)
    c1.save!

    c2 = Category.new(:name => 'wrong', :environment_id => 1)
    c1.children << c2

    assert !c2.valid?
    assert c2.errors.invalid?(:type)

    c3 = ProductCategory.new(:name => 'right', :environment_id => 1)
    c1.children << c3
    assert c3.valid?
    assert !c3.errors.invalid?(:type)
  end
end
