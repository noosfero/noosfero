require File.dirname(__FILE__) + '/../test_helper'

# FIXME move the filesystem-related tests out here
class CategoryTest < ActiveSupport::TestCase

  def setup
    @env = fast_create(Environment)
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
    c = build(Category, :environment_id => @env.id)
    assert_equal @env, c.environment
  end

  def test_relation_with_parent
    parent_category = fast_create(Category)
    c = build(Category, :parent_id => parent_category.id)
    assert_equal parent_category, c.parent
  end

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
    cat = fast_create(Category, :environment_id => @env.id)
    sub_cat = fast_create(Category, :environment_id => @env.id, :parent_id => cat.id)

    roots = Category.top_level_for(@env)

    assert_equal 1, roots.size
  end

  def test_slug
    c = Category.new(:name => 'Category name')
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
    root1 = fast_create(Category, :name => 'root category 1', :environment_id => @env.id)
    root2 = fast_create(Category, :name => 'root category 2', :environment_id => @env.id)
    child1 = fast_create(Category, :name => 'test category', :environment_id => @env.id, :parent_id => root1.id)

    child2 = Category.new(:name => 'test category', :environment_id => @env.id, :parent => root2)
    assert child2.valid?

    newroot = Category.new(:name => 'test category', :environment_id => @env.id, :parent => nil)
    assert newroot.valid?
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
    c1 = fast_create(Category, :name => 'test category', :environment_id => @env.id, :display_color => 1)

    c = Category.new(:name => 'lalala', :environment_id => @env.id)
    c.display_color = 1
    assert !c.valid?
    assert c.errors.invalid?(:display_color)

    c.display_color = 2
    c.valid?
    assert !c.errors.invalid?(:display_color)

  end

  should 'be able to get top ancestor' do
    c1 = fast_create(Category, :name => 'test category', :environment_id => @env.id)
    c2 = fast_create(Category, :name => 'test category', :environment_id => @env.id, :parent_id => c1.id)
    c3 = fast_create(Category, :name => 'test category', :environment_id => @env.id, :parent_id => c2.id)

    assert_equal c1, c1.top_ancestor
    assert_equal c1, c2.top_ancestor
    assert_equal c1, c3.top_ancestor
  end

  should 'explode path' do
    c1 = Category.new
    c1.expects(:path).returns("path/to/myself")
    assert_equal [ 'path', 'to', 'myself'], c1.explode_path
  end

  ################################################################
  # category filter stuff
  ################################################################

  should 'should paginate recent-like methods' do
    c = @env.categories.build(:name => 'my category'); c.save!
    assert c.recent_people.respond_to? 'total_entries'
    assert c.recent_enterprises.respond_to? 'total_entries'
    assert c.recent_communities.respond_to? 'total_entries'
    assert c.recent_products.respond_to? 'total_entries'
    assert c.recent_articles.respond_to? 'total_entries'
    assert c.recent_comments.respond_to? 'total_entries'
    assert c.most_commented_articles.respond_to? 'total_entries'
  end

  should 'list recent people' do
    c = @env.categories.build(:name => 'my category'); c.save!
    p1 = create_user('testuser').person
    p1.add_category c
    p1.save!

    p2 = create_user('testuser2').person
    p2.add_category c
    p2.save!

    assert_equal [p2, p1], c.recent_people
  end

  should 'list recent enterprises' do
    c = @env.categories.build(:name => 'my category'); c.save!
    ent1 = fast_create(Enterprise, :identifier => 'enterprise_1', :name => 'Enterprise one')
    ent1.add_category c
    ent2 = fast_create(Enterprise, :identifier => 'enterprise_2', :name => 'Enterprise one')
    ent2.add_category c

    assert_equal [ent2, ent1], c.recent_enterprises
  end

  should 'list recent communities' do
    c = @env.categories.build(:name => 'my category'); c.save!
    c1 = fast_create(Community, :name => 'testcommunity_1')
    c1.add_category c
    c2 = fast_create(Community, :name => 'testcommunity_2')
    c2.add_category c

    assert_equal [c2, c1], c.recent_communities
  end

  should 'list recent products' do
    product_category = fast_create(ProductCategory, :name => 'Products', :environment_id => Environment.default.id)
    c = @env.categories.build(:name => 'my category'); c.save!
    ent1 = fast_create(Enterprise, :identifier => 'enterprise_1', :name => 'Enterprise one')
    ent1.add_category c
    ent2 = fast_create(Enterprise, :identifier => 'enterprise_2', :name => 'Enterprise one')
    ent2.add_category c
    prod1 = ent1.products.create!(:name => 'test_prod1', :product_category => product_category)
    prod2 = ent2.products.create!(:name => 'test_prod2', :product_category => product_category)
    assert_equal [prod2, prod1], c.recent_products
  end

  should 'list recent articles' do
    c = @env.categories.build(:name => 'my category'); c.save!
    person = create_user('testuser').person

    a1 = person.articles.build(:name => 'art1')
    a1.add_category c
    a1.save!

    a2 = person.articles.build(:name => 'art2')
    a2.add_category c
    a2.save!

    assert_equal [a2, a1], c.recent_articles
  end

  should 'list recent comments' do
    c = @env.categories.build(:name => 'my category'); c.save!
    person = create_user('testuser').person

    a1 = person.articles.build(:name => 'art1')
    a1.add_category c
    a1.save!
    c1 = a1.comments.build(:title => 'comm1', :body => 'khdkashd ', :author => person); c1.save!

    a2 = person.articles.build(:name => 'art2')
    a2.add_category c
    a2.save!
    c2 = a2.comments.build(:title => 'comm1', :body => 'khdkashd ', :author => person); c2.save!

    assert_equal [c2, c1], c.recent_comments
  end

  should 'list most commented articles' do
    c = @env.categories.build(:name => 'my category'); c.save!
    person = create_user('testuser').person

    a1 = person.articles.build(:name => 'art1', :category_ids => [c.id]); a1.save!
    a2 = person.articles.build(:name => 'art2', :category_ids => [c.id]); a2.save!
    a3 = person.articles.build(:name => 'art3', :category_ids => [c.id]); a3.save!

    Comment.create(:title => 'test', :body => 'asdsa', :author => person, :source => a1)
    5.times { Comment.create(:title => 'test', :body => 'asdsa', :author => person, :source => a2) }

    10.times { Comment.create(:title => 'test', :body => 'kajsdsa', :author => person, :source => a3) }

    assert_equal [a3, a2], c.most_commented_articles(2)
  end

  should 'have comments' do
    c = @env.categories.build(:name => 'my category'); c.save!
    person = create_user('testuser').person

    a1 = person.articles.build(:name => 'art1', :category_ids => [c.id]); a1.save!
    a2 = person.articles.build(:name => 'art2', :category_ids => [c.id]); a2.save!
    a3 = person.articles.build(:name => 'art3', :category_ids => [c.id]); a3.save!

    c1 = a1.comments.build(:title => 'test', :body => 'asdsa', :author => person); c1.save!
    c2 = a2.comments.build(:title => 'test', :body => 'asdsa', :author => person); c2.save!
    c3 = a3.comments.build(:title => 'test', :body => 'asdsa', :author => person); c3.save!

    assert_equivalent [c1, c2, c3], c.comments
  end

  should 'have enterprises' do
    c = @env.categories.build(:name => 'my category'); c.save!
    ent1 = fast_create(Enterprise, :identifier => 'enterprise_1', :name => 'Enterprise one')
    ent1.add_category c
    ent2 = fast_create(Enterprise, :identifier => 'enterprise_2', :name => 'Enterprise one')
    ent2.add_category c
    assert_includes c.enterprises, ent1
    assert_includes c.enterprises, ent2
  end

  should 'have people' do
    c = @env.categories.build(:name => 'my category'); c.save!
    p1 = create_user('testuser_1').person
    p1.add_category c
    p2 = create_user('testuser_2').person
    p2.add_category c
    assert_equal [p1, p2], c.people
  end

  should 'have communities' do
    c = @env.categories.build(:name => 'my category'); c.save!
    c1 = fast_create(Community, :name => 'testcommunity_1')
    c1.add_category c
    c2 = fast_create(Community, :name => 'testcommunity_2')
    c2.add_category c
    assert_equal [c1, c2], c.communities
  end

  should 'have products through enteprises' do
    product_category = fast_create(ProductCategory, :name => 'Products', :environment_id => Environment.default.id)
    c = @env.categories.build(:name => 'my category'); c.save!
    ent1 = fast_create(Enterprise, :identifier => 'enterprise_1', :name => 'Enterprise one')
    ent1.add_category c
    ent2 = fast_create(Enterprise, :identifier => 'enterprise_2', :name => 'Enterprise one')
    ent2.add_category c
    prod1 = ent1.products.create!(:name => 'test_prod1', :product_category => product_category)
    prod2 = ent2.products.create!(:name => 'test_prod2', :product_category => product_category)
    assert_includes c.products, prod1
    assert_includes c.products, prod2
  end

  should 'not have person through communities' do
    c = @env.categories.build(:name => 'my category'); c.save!
    com = fast_create(Community, :identifier => 'community_1', :name => 'Community one')
    com.add_category c
    person = create_user('test_user').person
    person.add_category c
    assert_includes c.communities, com
    assert_not_includes c.communities, person
  end

  should 'not have person through enterprises' do
    c = @env.categories.build(:name => 'my category'); c.save!
    ent = fast_create(Enterprise, :identifier => 'enterprise_1', :name => 'Enterprise one')
    ent.add_category c
    person = create_user('test_user').person
    person.add_category c
    assert_includes c.enterprises, ent
    assert_not_includes c.enterprises, person
  end

  should 'not have enterprises through people' do
    c = @env.categories.build(:name => 'my category'); c.save!
    person = create_user('test_user').person
    person.add_category c
    ent = fast_create(Enterprise, :identifier => 'enterprise_1', :name => 'Enterprise one')
    ent.add_category c
    assert_includes c.people, person
    assert_not_includes c.people, ent
  end

  should 'have image' do
    assert_difference Category, :count do
      c = Category.create!(:name => 'test category1', :environment => Environment.default, :image_builder => {
        :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
      })
      assert_equal c.image(true).filename, 'rails.png'
    end
  end

  should 'display in menu only if have display_menu setted to true' do
    c   = fast_create(Category, :display_in_menu => true)
    c1  = fast_create(Category, :display_in_menu => true, :parent_id => c.id)
    c11 = fast_create(Category, :display_in_menu => true, :parent_id => c1.id)
    c2  = fast_create(Category, :display_in_menu => true, :parent_id => c.id)
    c3  = fast_create(Category, :parent_id => c.id)

    assert_equivalent [c1, c11, c2], c.children_for_menu
  end

  should 'cache children count' do
    c = Category.create!(:name => 'test', :environment => Environment.default)

    # two children catagories
    c.children.create!(:name => 'test1', :environment => Environment.default)
    c.children.create!(:name => 'test2', :environment => Environment.default)

    c.reload

    assert_equal 2, c.children_count
    assert_equal 2, c.children.size
  end

  should 'accept_products is true by default' do
    assert Category.new.accept_products?
  end

  should 'get categories by type including nil' do
    category = Category.create!(:name => 'test category', :environment => Environment.default)
    region = Region.create!(:name => 'test region', :environment => Environment.default)
    product = ProductCategory.create!(:name => 'test product', :environment => Environment.default)
    result = Category.from_types(['ProductCategory', '']).all
    assert_equal 2, result.size
    assert result.include?(product)
    assert result.include?(category)
  end

  should 'get categories by type and not nil' do
    category = Category.create!(:name => 'test category', :environment => Environment.default)
    region = Region.create!(:name => 'test region', :environment => Environment.default)
    product = ProductCategory.create!(:name => 'test product', :environment => Environment.default)
    result = Category.from_types(['Region', 'ProductCategory']).all
    assert_equal 2, result.size
    assert result.include?(region)
    assert result.include?(product)
  end

  should 'define a leaf to be displayed in menu' do
    c1 = fast_create(Category, :display_in_menu => true)
    c11  = fast_create(Category, :display_in_menu => true, :parent_id => c1.id)
    c2   = fast_create(Category, :display_in_menu => true)
    c21  = fast_create(Category, :display_in_menu => false, :parent_id => c2.id)
    c22  = fast_create(Category, :display_in_menu => false, :parent_id => c2.id)

    assert_equal false, c1.is_leaf_displayable_in_menu?
    assert_equal true, c11.is_leaf_displayable_in_menu?
    assert_equal true, c2.is_leaf_displayable_in_menu?
    assert_equal false, c21.is_leaf_displayable_in_menu?
    assert_equal false, c22.is_leaf_displayable_in_menu?
  end

  should 'filter top_level categories by type' do
    toplevel_productcategory = fast_create(ProductCategory)
    leaf_productcategory = fast_create(ProductCategory, :parent_id => toplevel_productcategory.id)

    toplevel_category = fast_create(Category)
    leaf_category = fast_create(Category, :parent_id => toplevel_category.id)

    assert_includes Category.top_level_for(Environment.default).from_types(['ProductCategory']), toplevel_productcategory
    assert_not_includes Category.top_level_for(Environment.default).from_types(['ProductCategory']), leaf_productcategory
    assert_not_includes Category.top_level_for(Environment.default).from_types(['ProductCategory']), toplevel_category
  end

  should 'paginate upcoming events' do
    category = Category.create!(:name => 'category1', :environment_id => Environment.default.id)
    profile = fast_create(Profile)
    event1 = category.events.build(:name => 'event1', :start_date => Time.now, :profile => profile)	
    event2 = category.events.build(:name => 'event2', :start_date => Time.now + 1.hour, :profile => profile)	
    event3 = category.events.build(:name => 'event3', :start_date => Time.now + 1.day, :profile => profile)
    category.save!
    assert_equal [event1, event2], category.upcoming_events(2)
  end

  should 'remove all article categorizations when destroyed' do
    cat = Category.create!(:name => 'category 1', :environment_id => Environment.default.id)
    art = Article.create!(:name => 'article 1', :profile_id => fast_create(Person).id)
    art.add_category cat
    cat.destroy
    assert art.categories.reload.empty?
  end

  should 'remove all profile categorizations when destroyed' do
    cat = Category.create!(:name => 'category 1', :environment_id => Environment.default.id)
    p = create(Person, :user_id => fast_create(User).id)
    p.add_category cat
    cat.destroy
    assert p.categories.reload.empty?
  end

  should 'act as searchable' do
    TestSolr.enable
    parent = fast_create(Category, :name => 'books')
    c = Category.create!(:name => "science fiction", :acronym => "sf", :abbreviation => "sci-fi",
                         :environment_id => Environment.default.id, :parent_id => parent.id)

    # fields
    assert_includes Category.find_by_contents('fiction')[:results].docs, c
    assert_includes Category.find_by_contents('sf')[:results].docs, c
    assert_includes Category.find_by_contents('sci-fi')[:results].docs, c
    # filters
    assert_includes Category.find_by_contents('science', {}, {
      :filter_queries => ["parent_id:#{parent.id}"]})[:results].docs, c
  end

  should 'boost name matches' do
    TestSolr.enable
    c_abbr = Category.create!(:name => "something else", :abbreviation => "science", :environment_id => Environment.default.id)
    c_name = Category.create!(:name => "science fiction", :environment_id => Environment.default.id)
    assert_equal [c_name, c_abbr], Category.find_by_contents("science")[:results].docs
  end

  should 'solr save' do
    c = @env.categories.build(:name => 'my category');
    c.expects(:solr_save)
    c.save!
  end

  should 'reindex articles after saving' do
    cat = Category.create!(:name => 'category 1', :environment_id => Environment.default.id)
    art = Article.create!(:name => 'something', :profile_id => fast_create(Person).id)
    art.add_category cat
    cat.reload

    solr_doc = art.to_solr_doc
    Article.any_instance.expects(:to_solr_doc).returns(solr_doc)
    cat.save!
  end

  should 'return categories of a level' do
    c1 = fast_create(Category)
    c2 = fast_create(Category)
    c3 = fast_create(Category, :parent_id => c1)
    c4 = fast_create(Category, :parent_id => c1)
    c5 = fast_create(Category, :parent_id => c2)
    c6 = fast_create(Category, :parent_id => c3)

    assert_includes Category.on_level(nil), c1
    assert_includes Category.on_level(nil), c2
    assert_includes Category.on_level(c1), c3
    assert_includes Category.on_level(c1), c4
    assert_includes Category.on_level(c2), c5
    assert_includes Category.on_level(c3), c6
  end

  should 'on level named_scope must be able to receive parent or parent_id' do
    parent = fast_create(Category)
    category = fast_create(Category, :parent_id => parent)

    assert_includes Category.on_level(parent), category
    assert_includes Category.on_level(parent.id), category
  end

  should 'list category sub-categories' do
    c1 = Category.create!(:name => 'Category 1', :environment => Environment.default)
    c2 = Category.create!(:name => 'Category 2', :environment => Environment.default)
    c3 = Category.create!(:name => 'Category 3', :environment => Environment.default, :parent_id => c1)
    c4 = Category.create!(:name => 'Category 4', :environment => Environment.default, :parent_id => c1)
    c5 = Category.create!(:name => 'Category 5', :environment => Environment.default, :parent_id => c3)

    sub_categories = Category.sub_categories(c1)

    assert ActiveRecord::NamedScope::Scope, sub_categories.class
    assert_not_includes sub_categories, c1
    assert_not_includes sub_categories, c2
    assert_includes sub_categories, c3
    assert_includes sub_categories, c4
    assert_includes sub_categories, c5
  end

  should 'list category sub-tree' do
    c1 = Category.create!(:name => 'Category 1', :environment => Environment.default)
    c2 = Category.create!(:name => 'Category 2', :environment => Environment.default)
    c3 = Category.create!(:name => 'Category 3', :environment => Environment.default, :parent_id => c1)
    c4 = Category.create!(:name => 'Category 4', :environment => Environment.default, :parent_id => c1)
    c5 = Category.create!(:name => 'Category 5', :environment => Environment.default, :parent_id => c3)

    sub_tree = Category.sub_tree(c1)

    assert ActiveRecord::NamedScope::Scope, sub_tree.class
    assert_includes sub_tree, c1
    assert_not_includes sub_tree, c2
    assert_includes sub_tree, c3
    assert_includes sub_tree, c4
    assert_includes sub_tree, c5
  end

end
