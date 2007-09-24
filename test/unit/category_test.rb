require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase

  def setup
    @env = Environment.create!(:name => 'Enviroment for testing')
  end

  def test_mandatory_field_name
    c = Category.new
    c.organization = @env
    c.save
    assert c.errors.invalid?(:name)
  end

  def test_mandatory_field_name
    c = Category.new
    c.name = 'product category for testing'
    assert !c.valid?
    assert c.errors.invalid?(:environment_id)
  end

  def test_relationship_with_environment
    c = Category.create!(:name => 'product category for testing', :environment_id => @env.id)
    assert_equal @env, c.environment
  end

  def test_relation_with_parent
    parent_category = Category.create!(:name => 'parent category for testing', :environment_id => @env.id)
    c = Category.create!(:name => 'product category for testing', :environment_id => @env.id, :parent_id => parent_category.id)
    assert_equal parent_category, c.parent
  end

  # def test_full_text_search
  #   c = Category.create!(:name => 'product category for testing', :environment_id => @env.id)
  #   assert @env.product_categories.full_text_search('product*').include?(c)
  # end

  def test_category_full_name
    cat = Category.new(:name => 'category_name')
    assert_equal 'category_name', cat.full_name
  end

  def test_subcategory_full_name
    cat = Category.new(:name => 'category_name')
    sub_cat = Category.new(:name => 'subcategory_name')
    sub_cat.stubs(:parent).returns(cat)
    sub_cat.parent = cat
    assert_equal 'category_name/subcategory_name', sub_cat.full_name
  end

  def test_category_level
    cat = Category.new(:name => 'category_name')
    assert_equal 0, cat.level
  end

  def test_subegory_level
    cat = Category.new(:name => 'category_name')
    sub_cat = Category.new(:name => 'subcategory_name')
    sub_cat.stubs(:parent).returns(cat)
    sub_cat.parent = cat
    assert_equal 1, sub_cat.level
  end

  def test_top_level
    cat = Category.new(:name => 'category_name')
    assert cat.top_level?
  end

  def test_not_top_level
    cat = Category.new(:name => 'category_name')
    sub_cat = Category.new(:name => 'subcategory_name')
    sub_cat.stubs(:parent).returns(cat)
    sub_cat.parent = cat
    assert !sub_cat.top_level?
  end

  def test_leaf
    cat = Category.new(:name => 'category_name')
    sub_cat = Category.new(:name => 'subcategory_name')
    cat.stubs(:children).returns([sub_cat])
    assert !cat.leaf?
  end

  def test_not_leaf
    cat = Category.new(:name => 'category_name')
    sub_cat = Category.new(:name => 'subcategory_name')
    cat.stubs(:children).returns([])
    assert cat.leaf?
  end

  def test_top_level_for
    cat = Category.create(:name => 'Category for testing', :environment_id => @env.id)
    sub_cat = Category.create(:name => 'SubCategory for testing', :environment_id => @env.id, :parent_id => cat.id)

    roots = Category.top_level_for(@env)
    
    assert_equal 1, roots.size
  end
 
  def test_slug
    c = Category.create(:name => 'Category name')
    assert_equal 'category-name', c.slug
  end

  def test_path_for_toplevel
    c = Category.new(:name => 'top_level')
    assert_equal 'top-level', c.path
  end

  def test_path_for_subcategory
    c1 = Category.new(:name => 'parent')

    c2 = Category.new
    c2.parent = c1
    c2.name = 'child'

    assert_equal 'parent/child', c2.path
  end

  def test_should_set_path_correctly_before_saving
    c1 = Category.create!(:name => 'parent', :environment_id => @env.id)

    c2 = Category.new(:name => 'child', :environment_id => @env.id)
    c2.parent = c1
    c2.save!

    assert_equal 'parent/child', c2.path
  end

  def test_should_refuse_to_duplicate_slug_under_the_same_parent
    c1 = Category.create!(:name => 'test category', :environment_id => @env.id)
    c2 = Category.new(:name => 'Test: Category', :environment_id => @env.id)

    assert !c2.valid?
    assert c2.errors.invalid?(:slug)

  end

end
