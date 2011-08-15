require File.dirname(__FILE__) + '/../test_helper'

class CategoryFinderTest < ActiveSupport::TestCase

  def setup
    @category = Category.create!(:name => 'my category', :environment => Environment.default)
    @finder = CategoryFinder.new(@category)
    @product_category = fast_create(ProductCategory, :name => 'Products')

    Comment.skip_captcha!
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
    ent2 = fast_create(Enterprise, :name => 'beautiful enterprise 2', :identifier => 'test2')

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
    c1 = fast_create(Community, :name => 'a beautiful community', :identifier => 'bea_comm', :environment_id => Environment.default.id)
    c2 = fast_create(Community, :name => 'another beautiful community', :identifier => 'an_bea_comm', :environment_id => Environment.default.id)
    c1.add_category(@category); c1.save!

    list = @finder.find(:communities, 'beautiful')
    assert_includes list, c1
    assert_not_includes list, c2
  end

  should 'search for products in a specific category' do
    ent1 = fast_create(Enterprise, :name => 'teste1', :identifier => 'teste1'); ent1.add_category(@category)
    ent2 = fast_create(Enterprise, :name => 'teste2', :identifier => 'teste2')
    prod1 = ent1.products.create!(:name => 'a beautiful product', :product_category => @product_category)
    prod2 = ent2.products.create!(:name => 'another beautiful product', :product_category => @product_category)

    list = @finder.find(:products, 'beautiful')
    assert_includes list, prod1
    assert_not_includes list, prod2
  end

  should 'search people in category hierarchy' do
    parent = fast_create(Category, :name => 'parent category', :environment_id => Environment.default.id)
    child  = fast_create(Category, :name => 'child category', :environment_id => Environment.default.id, :parent_id => parent.id)
    p1 = create_user('people_1').person
    p1.name = 'a beautiful person'
    p1.add_category(child)
    p1.save!

    parent.reload

    f = CategoryFinder.new(parent)
    assert_includes f.find(:people, 'beautiful'), p1
  end

  should 'search article in category hierarchy' do
    parent = fast_create(Category, :name => 'parent category', :environment_id => Environment.default.id)
    child  = fast_create(Category, :name => 'child category', :environment_id => Environment.default.id, :parent_id => parent.id)

    p1 = create_user('people_1').person

    article = p1.articles.create!(:name => 'a beautiful article', :category_ids => [child.id])

    parent.reload

    f = CategoryFinder.new(parent)
    assert_includes f.find(:articles, 'beautiful'), article
  end

  should 'list recent enterprises' do
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste', :category_ids => [@category.id])
    assert_includes @finder.recent('enterprises'), ent
  end
  
  should 'respond to total_entries in the recent enterprises result' do
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste', :category_ids => [@category.id])
    assert_respond_to @finder.recent('enterprises'), :total_entries
  end

  should 'not list more enterprises than limit' do
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1', :category_ids => [@category.id])
    ent2 = Enterprise.create!(:name => 'teste2', :identifier => 'teste2', :category_ids => [@category.id])
    result = @finder.recent('enterprises', 1)
    
    assert_equal 1, result.size
  end
  
  should 'paginate the list of more enterprises than limit' do
    ent1 = Enterprise.create!(:name => 'teste1', :identifier => 'teste1', :category_ids => [@category.id])
    ent2 = Enterprise.create!(:name => 'teste2', :identifier => 'teste2', :category_ids => [@category.id])

    page_1 = @finder.find('enterprises', nil, :per_page => 1, :page => 1)
    page_2 = @finder.find('enterprises', nil, :per_page => 1, :page => 2)
    
    assert_equal 1, page_1.size
    assert_equal 1, page_2.size
    assert_equivalent [ent1, ent2], page_1 + page_2
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
  
  should 'not list more people than limit' do
    p1 = create_user('test1').person; p1.add_category(@category)
    p2 = create_user('test2').person; p2.add_category(@category)
    result = @finder.recent('people', 1)
    
    assert_equal 1, result.size
  end

  should 'list recent articles' do
    person = create_user('teste').person
    art1 = person.articles.create!(:name => 'an article to be found', :category_ids => [@category.id])
    art2 = person.articles.create!(:name => 'another article to be found', :category_ids => [@category.id])

    result = @finder.recent('articles', 1)
    
    assert_equal [art2], result
  end

  should 'not return the same result twice' do
    parent = fast_create(Category, :name => 'parent category', :environment_id => Environment.default.id)
    child  = fast_create(Category, :name => 'child category', :environment_id => Environment.default.id, :parent_id => parent.id)
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

    result = @finder.most_commented_articles(2)
    # should respect the order (more commented comes first)
    assert_equal [articles[1], articles[0]], result
    assert_respond_to result, :total_entries
  end

  should 'find person and enterprise by radius and region' do
    finder = CategoryFinder.new(@category)
    
    region = fast_create(Region, :name => 'r-test', :environment_id => Environment.default.id, :lat => 45.0, :lng => 45.0)
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
    e2 = fast_create(Event, :name => 'e2', :profile_id => person.id, :start_date => Date.new(2008,1,15))

    events = finder.current_events(2008, 1)
    assert_includes events, e1
    assert_not_includes events, e2
  end

  should 'list upcoming events' do
    person = create_user('testuser').person

    Date.expects(:today).returns(Date.new(2008, 1, 15)).at_least_once

    past_event = Event.create!(:name => 'past event', :profile => person, :start_date => Date.new(2008,1,1), :category_ids => [@category.id])

    # event 2 is created after, but must be listed before (since it happens before)
    upcoming_event_2 = Event.create!(:name => 'upcoming event 2', :profile => person, :start_date => Date.new(2008,1,25), :category_ids => [@category.id])
    upcoming_event_1 = Event.create!(:name => 'upcoming event 1', :profile => person, :start_date => Date.new(2008,1,20), :category_ids => [@category.id])
    not_in_category = fast_create(Event, :name => 'e1', :profile_id => person.id, :start_date => Date.new(2008,1,20))

    assert_equal [upcoming_event_1, upcoming_event_2], @finder.upcoming_events
  end

  should 'find person and enterprise in category by radius and region even without query' do
    cat = fast_create(Category, :name => 'test category', :environment_id => Environment.default.id)
    finder = CategoryFinder.new(cat)

    region = fast_create(Region, :name => 'r-test', :environment_id => Environment.default.id, :lat => 45.0, :lng => 45.0)
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
    cat = fast_create(Category, :name => 'test category', :environment_id => Environment.default.id)
    finder = CategoryFinder.new(cat)

    prod_cat = fast_create(ProductCategory, :name => 'test product category', :environment_id => Environment.default.id)
    ent = Enterprise.create!(:name => 'test enterprise', :identifier => 'test_ent', :category_ids => [cat.id])
    prod1 = ent.products.create!(:name => 'test product 1', :product_category => prod_cat)
    prod2 = ent.products.create!(:name => 'test product 2', :product_category => @product_category)

    prods = finder.find(:products, nil, :product_category => prod_cat)

    assert_includes prods, prod1
    assert_not_includes prods, prod2
  end

  should 'find enterprises by its products categories without query' do
    pc1 = fast_create(ProductCategory, :name => 'test_cat1', :environment_id => Environment.default.id)
    pc2 = fast_create(ProductCategory, :name => 'test_cat2', :environment_id => Environment.default.id)

    ent1 = Enterprise.create!(:name => 'test enterprise 1', :identifier => 'test_ent1', :category_ids => [@category.id])
    ent1.products.create!(:name => 'test product 1', :product_category => pc1)
    ent2 = Enterprise.create!(:name => 'test enterprise 2', :identifier => 'test_ent2', :category_ids => [@category.id])
    ent2.products.create!(:name => 'test product 2', :product_category => pc2)

    ents = @finder.find(:enterprises, nil, :product_category => pc1)

    assert_includes ents, ent1
    assert_not_includes ents, ent2
  end
  
  should 'find enterprises by its products categories with query' do
    pc1 = fast_create(ProductCategory, :name => 'test_cat1', :environment_id => Environment.default.id)
    pc2 = fast_create(ProductCategory, :name => 'test_cat2', :environment_id => Environment.default.id)

    ent1 = Enterprise.create!(:name => 'test enterprise 1', :identifier => 'test_ent1', :category_ids => [@category.id])
    ent1.products.create!(:name => 'test product 1', :product_category => pc1)
    ent2 = Enterprise.create!(:name => 'test enterprise 2', :identifier => 'test_ent2', :category_ids => [@category.id])
    ent2.products.create!(:name => 'test product 2', :product_category => pc2)

    ents = @finder.find(:enterprises, 'test', :product_category => pc1)

    assert_includes ents, ent1
    assert_not_includes ents, ent2
  end

  should 'count product categories results by products' do
    pc1 = fast_create(ProductCategory, :name => 'test cat1', :environment_id => Environment.default.id)
    pc11 = fast_create(ProductCategory, :name => 'test cat11', :environment_id => Environment.default.id, :parent_id => pc1.id)
    pc2 = fast_create(ProductCategory, :name => 'test cat2', :environment_id => Environment.default.id)
    pc3 = fast_create(ProductCategory, :name => 'test cat3', :environment_id => Environment.default.id)

    ent = Enterprise.create!(:name => 'test enterprise 1', :identifier => 'test_ent1', :category_ids => [@category.id])
    p1 = ent.products.create!(:name => 'test product 1', :product_category => pc1)
    p2 = ent.products.create!(:name => 'test product 2', :product_category => pc11)
    p3 = ent.products.create!(:name => 'test product 3', :product_category => pc2)
    p4 = ent.products.create!(:name => 'test product 4', :product_category => pc2) # not in the count
    p5 = ent.products.create!(:name => 'test product 5', :product_category => pc3) # not in the count

    ent2 = fast_create(Enterprise, :name => 'test enterprise 2', :identifier => 'test_ent2')
    p6 = ent2.products.create!(:name => 'test product 6', :product_category => pc1)

    counts = @finder.product_categories_count(:products, [pc1.id, pc11.id, pc2.id], [p1.id, p2.id, p3.id, p5.id, p6.id] )

    assert_equal 2, counts[pc1.id]
    assert_equal 1, counts[pc11.id]
    assert_equal 1, counts[pc2.id]
    assert_nil counts[pc3.id]
  end
  
  should 'count product categories results by all products' do
    pc1 = fast_create(ProductCategory, :name => 'test cat1', :environment_id => Environment.default.id)
    pc11 = fast_create(ProductCategory, :name => 'test cat11', :environment_id => Environment.default.id, :parent_id => pc1.id)
    pc2 = fast_create(ProductCategory, :name => 'test cat2', :environment_id => Environment.default.id)
    pc3 = fast_create(ProductCategory, :name => 'test cat3', :environment_id => Environment.default.id)

    ent = Enterprise.create!(:name => 'test enterprise 1', :identifier => 'test_ent1', :category_ids => [@category.id])
    p1 = ent.products.create!(:name => 'test product 1', :product_category => pc1)
    p2 = ent.products.create!(:name => 'test product 2', :product_category => pc11)
    p3 = ent.products.create!(:name => 'test product 3', :product_category => pc2)
    p4 = ent.products.create!(:name => 'test product 4', :product_category => pc3) # not in the count
    
    ent2 = fast_create(Enterprise, :name => 'test enterprise 2', :identifier => 'test_ent2')
    p6 = ent2.products.create!(:name => 'test product 6', :product_category => pc1)


    counts = @finder.product_categories_count(:products, [pc1.id, pc11.id, pc2.id] )

    assert_equal 2, counts[pc1.id]
    assert_equal 1, counts[pc11.id]
    assert_equal 1, counts[pc2.id]
    assert_nil counts[pc3.id]
  end
  
  should 'count product categories results by enterprises' do
    pc1 = fast_create(ProductCategory, :name => 'test cat1', :environment_id => Environment.default.id)
    pc11 = fast_create(ProductCategory, :name => 'test cat11', :environment_id => Environment.default.id, :parent_id => pc1.id)
    pc2 = fast_create(ProductCategory, :name => 'test cat2', :environment_id => Environment.default.id)
    pc3 = fast_create(ProductCategory, :name => 'test cat3', :environment_id => Environment.default.id)

    ent1 = Enterprise.create!(:name => 'test enterprise 1', :identifier => 'test_ent1', :category_ids => [@category.id])
    ent1.products.create!(:name => 'test product 1', :product_category => pc1)
    ent1.products.create!(:name => 'test product 2', :product_category => pc1)
    ent2 = Enterprise.create!(:name => 'test enterprise 2', :identifier => 'test_ent2', :category_ids => [@category.id])
    ent2.products.create!(:name => 'test product 2', :product_category => pc11)
    ent3 = Enterprise.create!(:name => 'test enterprise 3', :identifier => 'test_ent3', :category_ids => [@category.id])
    ent3.products.create!(:name => 'test product 3', :product_category => pc2)
    ent4 = Enterprise.create!(:name => 'test enterprise 4', :identifier => 'test_ent4', :category_ids => [@category.id])
    ent4.products.create!(:name => 'test product 4', :product_category => pc2)
    ent5 = Enterprise.create!(:name => 'test enterprise 5', :identifier => 'test_ent5', :category_ids => [@category.id])
    ent5.products.create!(:name => 'test product 5', :product_category => pc2)
    ent5.products.create!(:name => 'test product 6', :product_category => pc3)

    ent6 = fast_create(Enterprise, :name => 'test enterprise 6', :identifier => 'test_ent6')
    p6 = ent2.products.create!(:name => 'test product 6', :product_category => pc1)

    counts = @finder.product_categories_count(:enterprises, [pc1.id, pc11.id, pc2.id], [ent1.id, ent2.id, ent3.id, ent4.id] )

    assert_equal 2, counts[pc1.id]
    assert_equal 1, counts[pc11.id]
    assert_equal 2, counts[pc2.id]
    assert_nil counts[pc3.id]
  end
  
  should 'count product categories results by all enterprises' do
    pc1 = fast_create(ProductCategory, :name => 'test cat1', :environment_id => Environment.default.id)
    pc11 = fast_create(ProductCategory, :name => 'test cat11', :environment_id => Environment.default, :parent_id => pc1.id)
    pc2 = fast_create(ProductCategory, :name => 'test cat2', :environment_id => Environment.default.id)
    pc3 = fast_create(ProductCategory, :name => 'test cat3', :environment_id => Environment.default.id)

    ent1 = Enterprise.create!(:name => 'test enterprise 1', :identifier => 'test_ent1', :category_ids => [@category.id])
    ent1.products.create!(:name => 'test product 1', :product_category => pc1)
    ent1.products.create!(:name => 'test product 2', :product_category => pc1)
    ent2 = Enterprise.create!(:name => 'test enterprise 2', :identifier => 'test_ent2', :category_ids => [@category.id])
    ent2.products.create!(:name => 'test product 2', :product_category => pc11)
    ent3 = Enterprise.create!(:name => 'test enterprise 3', :identifier => 'test_ent3', :category_ids => [@category.id])
    ent3.products.create!(:name => 'test product 3', :product_category => pc2)
    ent4 = Enterprise.create!(:name => 'test enterprise 4', :identifier => 'test_ent4', :category_ids => [@category.id])
    ent4.products.create!(:name => 'test product 4', :product_category => pc2)
    ent4.products.create!(:name => 'test product 5', :product_category => pc3)

    ent5 = fast_create(Enterprise, :name => 'test enterprise 5', :identifier => 'test_ent5')
    p6 = ent2.products.create!(:name => 'test product 6', :product_category => pc1)

    counts = @finder.product_categories_count(:enterprises, [pc1.id, pc11.id, pc2.id] )

    assert_equal 2, counts[pc1.id]
    assert_equal 1, counts[pc11.id]
    assert_equal 2, counts[pc2.id]
    assert_nil counts[pc3.id]
  end

  should 'find enterprises in alphabetical order of name' do
    ent1 = Enterprise.create!(:name => 'test enterprise B', :identifier => 'test_ent_b', :category_ids => [@category.id])
    ent2 = Enterprise.create!(:name => 'test enterprise A', :identifier => 'test_ent_a', :category_ids => [@category.id])
    ent3 = Enterprise.create!(:name => 'test enterprise C', :identifier => 'test_ent_c', :category_ids => [@category.id])

    ents = @finder.find(:enterprises, nil)

    assert ents.index(ent2) < ents.index(ent1), "expected #{ents.index(ent2)} be smaller than #{ents.index(ent1)}"
    assert ents.index(ent1) < ents.index(ent3), "expected #{ents.index(ent1)} be smaller than #{ents.index(ent3)}"
  end

  should 'search for text articles in a specific category' do
    person = create_user('teste').person

    # in category
    art1 = fast_create(TextileArticle, :name => 'an article to be found', :profile_id => person.id)
    art1.add_category(@category)
    art1.save!

    # not in category
    art2 = fast_create(TextileArticle, :name => 'another article to be found', :profile_id => person.id)

    list = @finder.find(:text_articles, 'found')
    assert_includes list, art1
    assert_not_includes list, art2
  end
  
  should 'find events in a date range' do
    person = create_user('testuser').person

    date_range = Date.new(2009, 11, 28)..Date.new(2009, 12, 3)

    event_in_range = Event.create!(:name => 'Event in range', :profile => person, :start_date => Date.new(2009, 11, 27), :end_date => date_range.last, :category_ids => [@category.id])
    event_out_of_range = Event.create!(:name => 'Event out of range', :profile => person, :start_date => Date.new(2009, 12, 4), :category_ids => [@category.id])

    events_found = @finder.find(:events, '', :date_range => date_range)

    assert_includes events_found, event_in_range
    assert_not_includes events_found, event_out_of_range
  end

  should 'not paginate events' do
    person = create_user('testuser').person

    create(:event, :profile_id => person.id, :category_ids => [@category.id])
    create(:event, :profile_id => person.id, :category_ids => [@category.id])

    assert_equal 2, @finder.find(:events, '', :per_page => 1).size
  end

  should 'not paginate events within a range' do
    person = create_user('testuser').person

    create(:event, :profile_id => person.id, :category_ids => [@category.id])
    create(:event, :profile_id => person.id, :category_ids => [@category.id])

    date_range = Date.today..Date.today
    assert_equal 2, @finder.find(:events, '', :date_range => date_range, :per_page => 1).size
  end

  should 'not paginate current events' do
    person = create_user('testuser').person

    create(:event, :profile_id => person.id, :category_ids => [@category.id])
    create(:event, :profile_id => person.id, :category_ids => [@category.id])

    assert_equal 2, @finder.current_events(Date.today.year, Date.today.month, :per_page => 1).size
  end

  should 'not paginate upcoming events' do
    person = create_user('testuser').person

    create(:event, :profile_id => person.id, :category_ids => [@category.id])
    create(:event, :profile_id => person.id, :category_ids => [@category.id])

    assert_equal 2, @finder.upcoming_events(:per_page => 1).size
  end

  should 'not paginate searching for specific event' do
    person = create_user('teste').person

    today = Date.today

    event_to_found1 = Event.create!(:name => 'ToFound 1', :profile => person, :category_ids => [@category.id], :start_date => today)
    event_to_found2 = Event.create!(:name => 'ToFound 2', :profile => person, :category_ids => [@category.id], :start_date => today)
    event_to_not_found1 = Event.create!(:name => 'ToNotFound 1', :profile => person, :category_ids => [@category.id], :start_date => today)
    event_to_not_found2 = Event.create!(:name => 'ToNotFound 2', :profile => person, :category_ids => [@category.id], :start_date => today)

    result = @finder.find(:events, 'ToFound', :per_page => 1)

    assert_includes result, event_to_found1
    assert_includes result, event_to_found2
    assert_not_includes result, event_to_not_found1
    assert_not_includes result, event_to_not_found2
  end

end
