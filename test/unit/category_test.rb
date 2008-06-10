require File.dirname(__FILE__) + '/../test_helper'

# FIXME move the filesystem-related tests out here
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

  should 'cope with nil name when calculating full_name' do
    cat = Category.new(:name => 'toplevel')
    sub = Category.new
    sub.parent = cat
    assert_equal 'toplevel/?', sub.full_name
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

  should 'be able to duplicated slug in different scope' do
    @env.categories.destroy_all

    root1 = Category.create!(:name => 'root category 1', :environment_id => @env.id)
    root2 = Category.create!(:name => 'root category 2', :environment_id => @env.id)

    assert_nothing_raised ActiveRecord::RecordInvalid do
      Category.create!(:name => 'test category', :environment_id => @env.id, :parent => root1)
      Category.create!(:name => 'test category', :environment_id => @env.id, :parent => root2)
    end
  end

  should 'be able to duplicated slug in different scope without parent' do
    @env.categories.destroy_all

    root1 = Category.create!(:name => 'root category 1', :environment_id => @env.id)

    assert_nothing_raised ActiveRecord::RecordInvalid do
      Category.create!(:name => 'test category', :environment_id => @env.id, :parent => root1)
      Category.create!(:name => 'test category', :environment_id => @env.id, :parent => nil)
    end
  end

  def test_renaming_a_category_should_change_path_of_children
    c1 = Category.create!(:name => 'parent', :environment_id => @env.id)
    c2 = Category.create!(:name => 'child', :environment_id => @env.id, :parent_id => c1.id)
    c3 = Category.create!(:name => 'grandchild', :environment_id => @env.id, :parent_id => c2.id)

    c1.name = 'parent new name'
    c1.save!

    assert_equal 'parent-new-name', c1.path
    assert_equal 'parent-new-name/child', Category.find(c2.id).path
    assert_equal 'parent-new-name/child/grandchild', Category.find(c3.id).path

  end

  should "limit the possibile display colors" do
    c = Category.new(:name => 'test category', :environment_id => @env.id)


    c.display_color = 10
    c.valid?
    assert c.errors.invalid?(:display_color)
    
    valid = %w[ 1 2 3 4 ].map { |item| item.to_i }
    valid.each do |item|
      c.display_color = item
      c.valid?
      assert !c.errors.invalid?(:display_color)
    end

  end

  should 'avoid duplicated display colors' do

    @env.categories.destroy_all

    c1 = Category.create!(:name => 'test category', :environment_id => @env.id, :display_color => 1)

    c = Category.new(:name => 'lalala', :environment_id => @env.id)
    c.display_color = 1
    assert !c.valid?
    assert c.errors.invalid?(:display_color)

    c.display_color = 2
    c.valid?
    assert !c.errors.invalid?(:display_color)
    
  end

  should 'be able to get top ancestor' do
    c1 = Category.create!(:name => 'test category', :environment_id => @env.id)
    c2 = Category.create!(:name => 'test category', :environment_id => @env.id, :parent_id => c1.id)
    c3 = Category.create!(:name => 'test category', :environment_id => @env.id, :parent_id => c2.id)

    assert_equal c1, c1.top_ancestor
    assert_equal c1, c2.top_ancestor
    assert_equal c1, c3.top_ancestor
  end

  should 'explode path' do
    c1 = Category.create!(:name => 'parent', :environment_id => @env.id)
    c2 = Category.create!(:name => 'child', :environment_id => @env.id, :parent_id => c1.id)

    assert_equal [ 'parent', 'child'], c2.explode_path
  end

  ################################################################
  # category filter stuff
  ################################################################

  should 'list recent articles' do
    c = @env.categories.build(:name => 'my category'); c.save!
    person = create_user('testuser').person

    a1 = person.articles.build(:name => 'art1')
    a1.categories << c
    a1.save!

    a2 = person.articles.build(:name => 'art2')
    a2.categories << c
    a2.save!

    assert_equivalent [a1, a2], c.recent_articles
  end

  should 'list recent comments' do
    c = @env.categories.build(:name => 'my category'); c.save!
    person = create_user('testuser').person

    a1 = person.articles.build(:name => 'art1')
    a1.categories << c
    a1.save!
    c1 = a1.comments.build(:title => 'comm1', :body => 'khdkashd ', :author => person); c1.save!

    a2 = person.articles.build(:name => 'art2')
    a2.categories << c
    a2.save!
    c2 = a2.comments.build(:title => 'comm1', :body => 'khdkashd ', :author => person); c2.save!

    assert_equivalent [c1, c2], c.recent_comments
  end

  should 'list most commented articles' do
    c = @env.categories.build(:name => 'my category'); c.save!
    person = create_user('testuser').person

    a1 = person.articles.build(:name => 'art1', :categories => [c]); a1.save!
    a2 = person.articles.build(:name => 'art2', :categories => [c]); a2.save!
    a3 = person.articles.build(:name => 'art3', :categories => [c]); a3.save!

    a1.comments.build(:title => 'test', :body => 'asdsa', :author => person).save!
    5.times { a2.comments.build(:title => 'test', :body => 'asdsa', :author => person).save! }

    10.times { a3.comments.build(:title => 'test', :body => 'kajsdsa', :author => person).save! }

    assert_equal [a3, a2], c.most_commented_articles(2)
  end
  should 'have comments' do
    c = @env.categories.build(:name => 'my category'); c.save!
    person = create_user('testuser').person

    a1 = person.articles.build(:name => 'art1', :categories => [c]); a1.save!
    a2 = person.articles.build(:name => 'art2', :categories => [c]); a2.save!
    a3 = person.articles.build(:name => 'art3', :categories => [c]); a3.save!

    c1 = a1.comments.build(:title => 'test', :body => 'asdsa', :author => person); c1.save!
    c2 = a2.comments.build(:title => 'test', :body => 'asdsa', :author => person); c2.save!
    c3 = a3.comments.build(:title => 'test', :body => 'asdsa', :author => person); c3.save!

    assert_equivalent [c1, c2, c3], c.comments
  end

  should 'have enterprises' do
    c = @env.categories.build(:name => 'my category'); c.save!
    ent1 = Enterprise.create!(:identifier => 'enterprise_1', :name => 'Enterprise one')
    ent1.categories << c
    ent2 = Enterprise.create!(:identifier => 'enterprise_2', :name => 'Enterprise one')
    ent2.categories << c
    assert_includes c.enterprises, ent1
    assert_includes c.enterprises, ent2
  end

  should 'have people' do
    c = @env.categories.build(:name => 'my category'); c.save!
    p1 = create_user('testuser_1').person
    p1.categories << c
    p2 = create_user('testuser_2').person
    p2.categories << c
    assert_equal [p1, p2], c.people
  end

  should 'have communities' do
    c = @env.categories.build(:name => 'my category'); c.save!
    c1 = Environment.default.communities.create!(:name => 'testcommunity_1')
    c1.categories << c
    c2 = Environment.default.communities.create!(:name => 'testcommunity_2')
    c2.categories << c
    assert_equal [c1, c2], c.communities
  end

  should 'have products through enteprises' do
    c = @env.categories.build(:name => 'my category'); c.save!
    ent1 = Enterprise.create!(:identifier => 'enterprise_1', :name => 'Enterprise one')
    ent1.categories << c
    ent2 = Enterprise.create!(:identifier => 'enterprise_2', :name => 'Enterprise one')
    ent2.categories << c
    prod1 = ent1.products.create!(:name => 'test_prod1')
    prod2 = ent2.products.create!(:name => 'test_prod2')
    assert_includes c.products, prod1
    assert_includes c.products, prod2
  end

  should 'not have person through communities' do
    c = @env.categories.build(:name => 'my category'); c.save!
    com = Community.create!(:identifier => 'community_1', :name => 'Community one')
    com.categories << c
    person = create_user('test_user').person
    person.categories << c
    assert_includes c.communities, com
    assert_not_includes c.communities, person
  end

  should 'not have person through enterprises' do
    c = @env.categories.build(:name => 'my category'); c.save!
    ent = Enterprise.create!(:identifier => 'enterprise_1', :name => 'Enterprise one')
    ent.categories << c
    person = create_user('test_user').person
    person.categories << c
    assert_includes c.enterprises, ent
    assert_not_includes c.enterprises, person
  end

  should 'not have enterprises through people' do
    c = @env.categories.build(:name => 'my category'); c.save!
    person = create_user('test_user').person
    person.categories << c
    ent = Enterprise.create!(:identifier => 'enterprise_1', :name => 'Enterprise one')
    ent.categories << c
    assert_includes c.people, person
    assert_not_includes c.people, ent
  end

  should 'report the total items in this category' do
    @category = Category.create!(:name => 'my category', :environment => @env)
    # in category
    person1 = create_user('test1').person; person1.categories << @category; person1.save!
    art1 = person1.articles.build(:name => 'an article to be counted'); art1.categories << @category; art1.save!
    comment1 = art1.comments.build(:title => 'comment to be counted', :body => 'hfyfyh', :author => person1); comment1.save!
    ent1 = Enterprise.create!(:name => 'test2', :identifier => 'test2', :categories => [@category])
    com1 = Community.create!(:name => 'test3', :identifier => 'test3', :categories => [@category])
    prod1 = Product.create!(:name => 'test4', :enterprise => ent1)

    # not in category
    person2 = create_user('test5').person
    art2 = person2.articles.build(:name => 'an article not to be counted'); art2.save!
    comment2 = art2.comments.build(:title => 'comment not to be counted', :body => 'hfh', :author => person2); comment2.save!
    ent2 = Enterprise.create!(:name => 'test6', :identifier => 'test6')
    com2 = Community.create!(:name => 'test7', :identifier => 'test7')
    prod2 = Product.create!(:name => 'test8', :enterprise => ent2)

    assert_equal 6, @category.total_items
  end

  # NOT YET
  #should 'list people that are categorized in children categories' do
  #  c1 = @env.categories.create!(:name => 'top category')
  #  c2 = @env.categories.create!(:name => 'child category', :parent => c1)
  #  person = create_user('test_user').person
  #  person.categories << c2
  #  assert_includes c1.people, person
  #end

  should 'have image' do
    assert_difference Category, :count do
      c = Category.create!(:name => 'test category1', :environment => Environment.default, :image_builder => {
        :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
      })
      assert_equal c.image(true).filename, 'rails.png'
    end
  end

  should 'display in menu only if have display_menu setted to true' do
    c = Category.create!(:name => 'test category top',  :environment => Environment.default, :display_in_menu => true)
    c1 = Category.create!(:name => 'test category 1',   :environment => Environment.default, :display_in_menu => true, :parent => c)
    c11 = Category.create!(:name => 'test category 11', :environment => Environment.default, :display_in_menu => true, :parent => c1)
    c2 = Category.create!(:name => 'test category 2',   :environment => Environment.default, :display_in_menu => true, :parent => c)
    c3 = Category.create!(:name => 'test category 3',   :environment => Environment.default, :parent => c)

    assert_equivalent [c1, c11, c2], c.children_for_menu
  end

end
