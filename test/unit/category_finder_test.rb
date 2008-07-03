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
    art1.add_category(@category)
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
    art1.add_category(@category)
    art1.save!

    # not in category
    art2 = person.articles.build(:name => 'another article to be found')
    art2.save!

    assert_includes @finder.find('articles', 'found'), art1
    assert_not_includes @finder.find('articles','found'), art2
  end

  should 'search for enterprises in a specific category' do

    # in category
    ent1 = Enterprise.create!(:name => 'beautiful enterprise 1', :identifier => 'test1', :category_ids => [@category.id])

    # not in category
    ent2 = Enterprise.create!(:name => 'beautiful enterprise 2', :identifier => 'test2')

    list = @finder.find(:enterprises, 'beautiful')
    assert_includes list, ent1
    assert_not_includes list, ent2
  end

  should 'search for people in a specific category' do
    p1 = create_user('people_1').person; p1.name = 'a beautiful person'; p1.add_category(@category); p1.save!
    p2 = create_user('people_2').person; p2.name = 'another beautiful person'; p2.save!

    list = @finder.find(:people, 'beautiful')
    assert_includes list, p1
    assert_not_includes list, p2
  end

  should 'search for communities in a specific category' do
    c1 = Community.create!(:name => 'a beautiful community', :identifier => 'bea_comm', :environment => Environment.default)
    c2 = Community.create!(:name => 'another beautiful community', :identifier => 'an_bea_comm', :environment => Environment.default)
    c1.add_category(@category); c1.save!

    list = @finder.find(:communities, 'beautiful')
    assert_includes list, c1
    assert_not_includes list, c2
  end

  should 'search for products in a specific category' do
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1'); ent1.add_category(@category)
    ent2 = Enterprise.create!(:name => 'teste2', :identifier => 'teste2')
    prod1 = ent1.products.create!(:name => 'a beautiful product')
    prod2 = ent2.products.create!(:name => 'another beautiful product')

    list = @finder.find(:products, 'beautiful')
    assert_includes list, prod1
    assert_not_includes list, prod2
  end

  should 'search people in category hierarchy' do
    parent = Category.create!(:name => 'parent category', :environment => Environment.default)
    child  = Category.create!(:name => 'child category', :environment => Environment.default, :parent => parent)
    p1 = create_user('people_1').person
    p1.name = 'a beautiful person'
    p1.add_category(child)
    p1.save!

    parent.reload

    f = CategoryFinder.new(parent)
    assert_includes f.find(:people, 'beautiful'), p1
  end

  should 'search article in category hierarchy' do
    parent = Category.create!(:name => 'parent category', :environment => Environment.default)
    child  = Category.create!(:name => 'child category', :environment => Environment.default, :parent => parent)

    p1 = create_user('people_1').person

    article = p1.articles.create!(:name => 'a beautiful article', :category_ids => [child.id])

    parent.reload

    f = CategoryFinder.new(parent)
    assert_includes f.find(:articles, 'beautiful'), article
  end

  should 'find communites by initial in category hierarchy' do
    parent = Category.create!(:name => 'parent category', :environment => Environment.default)
    child  = Category.create!(:name => 'child category', :environment => Environment.default, :parent => parent)
    p1 = create_user('people_1').person
    p1.name = 'person with inner beaity'
    p1.add_category(child)
    p1.save!

    parent.reload

    f = CategoryFinder.new(parent)
    assert_includes f.find_by_initial(:people, 'p'), p1
  end

  should 'find articles by initial in category hierarchy' do
    parent = Category.create!(:name => 'parent category', :environment => Environment.default)
    child  = Category.create!(:name => 'child category', :environment => Environment.default, :parent => parent)

    p1 = create_user('people_1').person

    article = p1.articles.create!(:name => 'fucking beautiful article', :category_ids => [child.id])

    parent.reload

    f = CategoryFinder.new(parent)
    assert_includes f.find_by_initial(:articles, 'f'), article
  end

  should 'list recent enterprises' do
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste', :category_ids => [@category.id])
    assert_includes @finder.recent('enterprises'), ent
  end

  should 'not list more enterprises than limit' do
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1', :category_ids => [@category.id])
    ent2 = Enterprise.create!(:name => 'teste2', :identifier => 'teste2', :category_ids => [@category.id])
    recent = @finder.recent('enterprises', 1)
    assert_includes recent, ent2
    assert_not_includes recent, ent1
  end
  
  should 'paginate the list of more enterprises than limit' do
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1', :category_ids => [@category.id])
    ent2 = Enterprise.create!(:name => 'teste2', :identifier => 'teste2', :category_ids => [@category.id])

    assert_equal [ent2], @finder.find('enterprises', nil, :per_page => 1, :page => 1)
    assert_equal [ent1], @finder.find('enterprises', nil, :per_page => 1, :page => 2)
  end
  
  should 'paginate the list of more enterprises than limit with query' do
    ent1 = Enterprise.create!(:name => 'teste 1', :identifier => 'teste1', :category_ids => [@category.id])
    ent2 = Enterprise.create!(:name => 'teste 2', :identifier => 'teste2', :category_ids => [@category.id])
    
    p1 = @finder.find('enterprises', 'teste', :per_page => 1, :page => 1)
    p2 = @finder.find('enterprises', 'teste', :per_page => 1, :page => 2)

    assert_respond_to p1, :total_entries
    assert_respond_to p2, :total_entries
    assert (p1 == [ent1] && p2 == [ent2]) || (p1 == [ent2] && p2 == [ent1]) # consistent paging
  end

  should 'count enterprises' do
    count = @finder.count('enterprises')
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1', :category_ids => [@category.id])
    assert_equal count+1, @finder.count('enterprises')
  end

   should 'count people' do
    count = @finder.count('people')
    p = create_user('testinguser').person
    p.category_ids = [@category.id]
    p.save!

    assert_equal count+1, @finder.count('people')
  end
  should 'count products' do
    count = @finder.count('products')
    
    ent = Enterprise.create!(:name => 'teste1', :identifier => 'teste1', :category_ids => [@category.id])
    ent.products.create!(:name => 'test prodduct')

    assert_equal count+1, @finder.count('products')
  end
  should 'count articles' do
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1')

    count = @finder.count('articles')
    ent1.articles.create!(:name => 'teste1', :category_ids => [@category.id])

    assert_equal count+1, @finder.count('articles')
  end
  should 'count events' do
    count = @finder.count('events')
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1')

    Event.create!(:name => 'teste2', :profile => ent1, :start_date => Date.today, :category_ids => [@category.id])
    assert_equal count+1, @finder.count('events')
  end

  should 'count enterprises with query and options' do
    results = mock

    @finder.expects(:find).with('people', 'my query', kind_of(Hash)).returns(results)

    results.expects(:total_hits).returns(99)

    assert_equal 99, @finder.count('people', 'my query', {})
  end
  
  should 'count enterprises without query but with options' do
    results = mock

    @finder.expects(:find).with('people', nil, kind_of(Hash)).returns(results)

    results.expects(:total_entries).returns(99)

    assert_equal 99, @finder.count('people', nil, {})
  end
  
  should 'not list more people than limit' do
    p1 = create_user('test1').person; p1.add_category(@category)
    p2 = create_user('test2').person; p2.add_category(@category)
    recent = @finder.recent('people', 1)
    assert_includes recent, p2
    assert_not_includes recent, p1
  end

  should 'list recent articles' do
    person = create_user('teste').person
    art1 = person.articles.build(:name => 'an article to be found'); art1.add_category(@category); art1.save!

    art2 = person.articles.build(:name => 'another article to be found'); art2.add_category(@category); art2.save!

    result = @finder.recent('articles', 1)
    assert_includes result, art2
    assert_not_includes result, art1
  end

  should 'not return the same result twice' do
    parent = Category.create!(:name => 'parent category', :environment => Environment.default)
    child  = Category.create!(:name => 'child category', :environment => Environment.default, :parent => parent)
    p1 = create_user('people_1').person
    p1.name = 'a beautiful person'
    p1.category_ids = [child.id, parent.id]; p1.save!

    f = CategoryFinder.new(parent)
    result = f.find(:people, 'beautiful')

    assert_equal [p1], result
    assert_equal 1, result.size
  end

  should 'return most commented articles' do
    Article.delete_all

    person = create_user('testuser').person
    articles = (1..4).map {|n| a = person.articles.build(:name => "art #{n}", :category_ids => [@category.id]); a.save!; a }

    2.times { articles[0].comments.build(:title => 'test', :body => 'asdsad', :author => person).save! }
    4.times { articles[1].comments.build(:title => 'test', :body => 'asdsad', :author => person).save! }

    # should respect the order (more commented comes first)
    assert_equal [articles[1], articles[0]], @finder.most_commented_articles(2)
  end

  should 'find people by initial' do
    p1 = create_user('aaaa').person; p1.add_category(@category)
    p2 = create_user('bbbb').person; p2.add_category(@category)

    list = CategoryFinder.new(@category).find_by_initial(:people, 'a')

    assert_includes list, p1
    assert_not_includes list, p2
  end

  should 'find enterprises by initial' do
    ent1 = Enterprise.create!(:name => 'aaaa', :identifier => 'aaaa'); ent1.add_category(@category)
    ent2 = Enterprise.create!(:name => 'bbbb', :identifier => 'bbbb'); ent2.add_category(@category)

    list = CategoryFinder.new(@category).find_by_initial(:enterprises, 'a')

    assert_includes list, ent1
    assert_not_includes list, ent2
  end

  should 'find communities by initial' do
    comm1 = Community.create!(:name => 'aaaa', :identifier => 'aaaa'); comm1.add_category(@category)
    comm2 = Community.create!(:name => 'bbbb', :identifier => 'bbbb'); comm2.add_category(@category)

    list = CategoryFinder.new(@category).find_by_initial(:communities, 'a')

    assert_includes list, comm1
    assert_not_includes list, comm2
  end

  should 'find products by initial' do
    ent = Enterprise.create!(:name => 'my enterprise', :identifier => 'myent')
    ent.add_category(@category)

    p1 = ent.products.create!(:name => 'A product')
    p2 = ent.products.create!(:name => 'Better product')

    list = CategoryFinder.new(@category).find_by_initial(:products, 'a')

    assert_includes list, p1
    assert_not_includes list, p2
  end

  should 'find articles by initial' do
    person = create_user('testuser').person
    a1 = person.articles.create!(:name => 'aaaa', :body => '...', :category_ids => [@category.id])
    a2 = person.articles.create!(:name => 'bbbb', :body => '...', :category_ids => [@category.id])

    list = CategoryFinder.new(@category).find_by_initial(:articles, 'a')

    assert_includes list, a1
    assert_not_includes list, a2
  end

  should 'find person and enterprise by radius and region' do
    finder = CategoryFinder.new(@category)
    
    region = Region.create!(:name => 'r-test', :environment => Environment.default, :lat => 45.0, :lng => 45.0)
    ent1 = Enterprise.create!(:name => 'test 1', :identifier => 'test1', :lat => 45.0, :lng => 45.0, :category_ids => [@category.id])
    p1 = create_user('test2').person
    p1.name = 'test 2'; p1.lat = 45.0; p1.lng = 45.0; p1.add_category(@category); p1.save!
    ent2 = Enterprise.create!(:name => 'test 3', :identifier => 'test3', :lat => 30.0, :lng => 30.0, :category_ids => [@category.id])
    p2 = create_user('test4').person
    p2.name = 'test 4'; p2.lat = 30.0; p2.lng = 30.0; p2.add_category(@category); p2.save!

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

    e1 = Event.create!(:name => 'e1', :profile => person, :start_date => Date.new(2008,1,1), :category_ids => [@category.id])

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
    ent1 = Enterprise.create!(:name => 'test 1', :identifier => 'test1', :lat => 45.0, :lng => 45.0, :category_ids => [cat.id])
    p1 = create_user('test2').person
    p1.name = 'test 2'; p1.lat = 45.0; p1.lng = 45.0; p1.add_category(cat); p1.save!
    ent2 = Enterprise.create!(:name => 'test 3', :identifier => 'test3', :lat => 30.0, :lng => 30.0, :category_ids => [cat.id])
    p2 = create_user('test4').person
    p2.name = 'test 4'; p2.lat = 30.0; p2.lng = 30.0; p2.add_category(cat); p2.save!

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
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent', :category_ids => [cat.id])
    prod1 = ent.products.create!(:name => 'test product 1', :product_category => prod_cat)
    prod2 = ent.products.create!(:name => 'test product 2')    

    prods = finder.find(:products, nil, :product_category => prod_cat)

    assert_includes prods, prod1
    assert_not_includes prods, prod2
  end

  should 'find enterprises by its products categories without query' do
    pc1 = ProductCategory.create!(:name => 'test_cat1', :environment => Environment.default)
    pc2 = ProductCategory.create!(:name => 'test_cat2', :environment => Environment.default)

    ent1 = Enterprise.create!(:name => 'test enterprise 1', :identifier => 'test_ent1', :category_ids => [@category.id])
    ent1.products.create!(:name => 'test product 1', :product_category => pc1)
    ent2 = Enterprise.create!(:name => 'test enterprise 2', :identifier => 'test_ent2', :category_ids => [@category.id])
    ent2.products.create!(:name => 'test product 2', :product_category => pc2)

    ents = @finder.find(:enterprises, nil, :product_category => pc1)

    assert_includes ents, ent1
    assert_not_includes ents, ent2
  end
  
  should 'find enterprises by its products categories with query' do
    pc1 = ProductCategory.create!(:name => 'test_cat1', :environment => Environment.default)
    pc2 = ProductCategory.create!(:name => 'test_cat2', :environment => Environment.default)

    ent1 = Enterprise.create!(:name => 'test enterprise 1', :identifier => 'test_ent1', :category_ids => [@category.id])
    ent1.products.create!(:name => 'test product 1', :product_category => pc1)
    ent2 = Enterprise.create!(:name => 'test enterprise 2', :identifier => 'test_ent2', :category_ids => [@category.id])
    ent2.products.create!(:name => 'test product 2', :product_category => pc2)

    ents = @finder.find(:enterprises, 'test', :product_category => pc1)

    assert_includes ents, ent1
    assert_not_includes ents, ent2
  end

end
