require File.dirname(__FILE__) + '/../test_helper'

class CategoryFinderTest < ActiveSupport::TestCase

  def setup
    @category = Category.create!(:name => 'my category', :environment => Environment.default)
    @finder = CategoryFinder.new(@category)
  end
	
  should 'search for articles in a specific category' do
    person = create_user('teste').person

    # in category
    art1 = person.articles.build(:name => 'an article to be found')
    art1.categories << @category
    art1.save!

    # not in category
    art2 = person.articles.build(:name => 'another article to be found')
    art2.save!

    list = @finder.find(:articles, 'found')
    assert_includes list, art1
    assert_not_includes list, art2
  end
  
  should 'search with query for articles in a specific category' do
    person = create_user('teste').person

    # in category
    art1 = person.articles.build(:name => 'an article to be found')
    art1.categories << @category
    art1.save!

    # not in category
    art2 = person.articles.build(:name => 'another article to be found')
    art2.save!

    assert_includes @finder.find('articles', 'found'), art1
    assert_not_includes @finder.find('articles','found'), art2
  end

  should 'search for enterprises in a specific category' do

    # in category
    ent1 = Enterprise.create!(:name => 'beautiful enterprise 1', :identifier => 'test1', :categories => [@category])

    # not in category
    ent2 = Enterprise.create!(:name => 'beautiful enterprise 2', :identifier => 'test2')

    list = @finder.find(:enterprises, 'beautiful')
    assert_includes list, ent1
    assert_not_includes list, ent2
  end

  should 'search for people in a specific category' do
    p1 = create_user('people_1').person; p1.name = 'a beautiful person'; p1.categories << @category; p1.save!
    p2 = create_user('people_2').person; p2.name = 'another beautiful person'; p2.save!

    list = @finder.find(:people, 'beautiful')
    assert_includes list, p1
    assert_not_includes list, p2
  end

  should 'search for communities in a specific category' do
    c1 = Community.create!(:name => 'a beautiful community', :identifier => 'bea_comm', :environment => Environment.default)
    c2 = Community.create!(:name => 'another beautiful community', :identifier => 'an_bea_comm', :environment => Environment.default)
    c1.categories << @category; c1.save!

    list = @finder.find(:communities, 'beautiful')
    assert_includes list, c1
    assert_not_includes list, c2
  end

  should 'search for products in a specific category' do
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1'); ent1.categories << @category
    ent2 = Enterprise.create!(:name => 'teste2', :identifier => 'teste2')
    prod1 = ent1.products.create!(:name => 'a beautiful product')
    prod2 = ent2.products.create!(:name => 'another beautiful product')

    list = @finder.find(:products, 'beautiful')
    assert_includes list, prod1
    assert_not_includes list, prod2
  end

  should 'load ids for category full hierarchy' do
    c1 = Category.create!(:name => 'parent', :environment => Environment.default)
    c2 = Category.create!(:name => 'child 1', :environment => Environment.default, :parent => c1)
    c3 = Category.create!(:name => 'grandchild', :environment => Environment.default, :parent => c2)
    c4 = Category.create!(:name => 'child 2', :environment => Environment.default, :parent => c1)
    c5 = Category.create!(:name => 'grandchild 2', :environment => Environment.default, :parent => c4)

    assert_equivalent [c1,c2,c3,c4,c5].map(&:id), CategoryFinder.new(c1).category_ids
  end

  should 'search in category hierarchy' do
    parent = Category.create!(:name => 'parent category', :environment => Environment.default)
    child  = Category.create!(:name => 'child category', :environment => Environment.default, :parent => parent)
    p1 = create_user('people_1').person; p1.name = 'a beautiful person'; p1.categories << child; p1.save!

    f = CategoryFinder.new(parent)
    assert_includes f.find(:people, 'beautiful'), p1
  end

  should 'list recent enterprises' do
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste', :categories => [@category])
    assert_includes @finder.recent('enterprises'), ent
  end

  should 'not list more enterprises than limit' do
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1', :categories => [@category])
    ent2 = Enterprise.create!(:name => 'teste2', :identifier => 'teste2', :categories => [@category])
    recent = @finder.recent('enterprises', 1)
    assert_includes recent, ent2
    assert_not_includes recent, ent1
  end

  should 'count entrprises' do
    count = @finder.count('enterprises')
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1', :categories => [@category])
    assert_equal count+1, @finder.count('enterprises')
  end
  
  should 'not list more people than limit' do
    p1 = create_user('test1').person; p1.categories << @category
    p2 = create_user('test2').person; p2.categories << @category
    recent = @finder.recent('people', 1)
    assert_includes recent, p2
    assert_not_includes recent, p1
  end

  should 'list recent articles' do
    person = create_user('teste').person
    art1 = person.articles.build(:name => 'an article to be found'); art1.categories << @category; art1.save!

    art2 = person.articles.build(:name => 'another article to be found'); art2.categories << @category; art2.save!

    result = @finder.recent('articles', 1)
    assert_includes result, art2
    assert_not_includes result, art1
  end

  should 'not return the same result twice' do
    parent = Category.create!(:name => 'parent category', :environment => Environment.default)
    child  = Category.create!(:name => 'child category', :environment => Environment.default, :parent => parent)
    p1 = create_user('people_1').person; p1.name = 'a beautiful person'; p1.categories << child; p1.save!
    p1.categories << parent; p1.save!

    f = CategoryFinder.new(parent)
    result = f.find(:people, 'beautiful')

    assert_equivalent [p1], result
    assert_equal 1, result.size
  end

  should 'return most commented articles' do
    Article.delete_all

    person = create_user('testuser').person
    articles = (1..4).map {|n| a = person.articles.build(:name => "art #{n}", :categories => [@category]); a.save!; a }

    2.times { articles[0].comments.build(:title => 'test', :body => 'asdsad', :author => person).save! }
    4.times { articles[1].comments.build(:title => 'test', :body => 'asdsad', :author => person).save! }

    # should respect the order (more commented comes first)
    assert_equal [articles[1], articles[0]], @finder.most_commented_articles(2)
  end

  should 'find people by initial' do
    p1 = create_user('aaaa').person; p1.categories << @category
    p2 = create_user('bbbb').person; p2.categories << @category

    list = CategoryFinder.new(@category).find_by_initial(:people, 'a')

    assert_includes list, p1
    assert_not_includes list, p2
  end

  should 'find enterprises by initial' do
    ent1 = Enterprise.create!(:name => 'aaaa', :identifier => 'aaaa'); ent1.categories << @category
    ent2 = Enterprise.create!(:name => 'bbbb', :identifier => 'bbbb'); ent2.categories << @category

    list = CategoryFinder.new(@category).find_by_initial(:enterprises, 'a')

    assert_includes list, ent1
    assert_not_includes list, ent2
  end

  should 'find communities by initial' do
    comm1 = Community.create!(:name => 'aaaa', :identifier => 'aaaa'); comm1.categories << @category
    comm2 = Community.create!(:name => 'bbbb', :identifier => 'bbbb'); comm2.categories << @category

    list = CategoryFinder.new(@category).find_by_initial(:communities, 'a')

    assert_includes list, comm1
    assert_not_includes list, comm2
  end

  should 'find products by initial' do
    ent = Enterprise.create!(:name => 'my enterprise', :identifier => 'myent')
    ent.categories << @category

    p1 = ent.products.create!(:name => 'A product')
    p2 = ent.products.create!(:name => 'Better product')

    list = CategoryFinder.new(@category).find_by_initial(:products, 'a')

    assert_includes list, p1
    assert_not_includes list, p2
  end

  should 'find articles by initial' do
    person = create_user('testuser').person
    a1 = person.articles.create!(:name => 'aaaa', :body => '...', :categories => [@category])
    a2 = person.articles.create!(:name => 'bbbb', :body => '...', :categories => [@category])

    list = CategoryFinder.new(@category).find_by_initial(:articles, 'a')

    assert_includes list, a1
    assert_not_includes list, a2
  end

  should 'find person and enterprise by radius and region' do
    finder = CategoryFinder.new(@category)
    
    region = Region.create!(:name => 'r-test', :environment => Environment.default, :lat => 45.0, :lng => 45.0)
    ent1 = Enterprise.create!(:name => 'test 1', :identifier => 'test1', :lat => 45.0, :lng => 45.0, :categories => [@category])
    p1 = create_user('test2').person
    p1.name = 'test 2'; p1.lat = 45.0; p1.lng = 45.0; p1.categories = [@category]; p1.save!
    ent2 = Enterprise.create!(:name => 'test 3', :identifier => 'test3', :lat => 30.0, :lng => 30.0, :categories => [@category])
    p2 = create_user('test4').person
    p2.name = 'test 4'; p2.lat = 30.0; p2.lng = 30.0; p2.categories = [@category]; p2.save!

    ents = finder.find(:enterprises, 'test', :within => 10, :region => region.id)
    people = finder.find(:people, 'test', :within => 10, :region => region.id)

    assert_includes ents, ent1
    assert_not_includes ents, ent2
    assert_includes people, p1
    assert_not_includes people, p2
  end

  should 'find current events' do
    finder = CategoryFinder.new(@category)
    person = create_user('testuser').person

    e1 = Event.create!(:name => 'e1', :profile => person, :start_date => Date.new(2008,1,1), :categories => [@category])

    # not in category
    e2 = Event.create!(:name => 'e2', :profile => person, :start_date => Date.new(2008,1,15))

    events = finder.current_events(2008, 1)
    assert_includes events, e1
    assert_not_includes events, e2
  end

  should 'find person and enterprise in category by radius and region even without query' do
    cat = Category.create!(:name => 'test category', :environment => Environment.default)
    finder = CategoryFinder.new(cat)

    region = Region.create!(:name => 'r-test', :environment => Environment.default, :lat => 45.0, :lng => 45.0)
    ent1 = Enterprise.create!(:name => 'test 1', :identifier => 'test1', :lat => 45.0, :lng => 45.0, :categories => [cat])
    p1 = create_user('test2').person
    p1.name = 'test 2'; p1.lat = 45.0; p1.lng = 45.0; p1.categories = [cat]; p1.save!
    ent2 = Enterprise.create!(:name => 'test 3', :identifier => 'test3', :lat => 30.0, :lng => 30.0, :categories => [cat])
    p2 = create_user('test4').person
    p2.name = 'test 4'; p2.lat = 30.0; p2.lng = 30.0; p2.categories = [cat]; p2.save!

    ents = finder.find(:enterprises, nil, :within => 10, :region => region.id)
    people = finder.find(:people, nil, :within => 10, :region => region.id)

    assert_includes ents, ent1
    assert_not_includes ents, ent2
    assert_includes people, p1
    assert_not_includes people, p2
  end

  should 'find products in category wihin product category' do
    cat = Category.create!(:name => 'test category', :environment => Environment.default)
    finder = CategoryFinder.new(cat)

    prod_cat = ProductCategory.create!(:name => 'test product category', :environment => Environment.default)
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent', :categories => [cat])
    prod1 = ent.products.create!(:name => 'test product 1', :product_category => prod_cat)
    prod2 = ent.products.create!(:name => 'test product 2')    

    prods = finder.find(:products, nil, :product_category => prod_cat)

    assert_includes prods, prod1
    assert_not_includes prods, prod2
  end

end
