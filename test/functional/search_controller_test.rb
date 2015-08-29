# encoding: UTF-8
require_relative "../test_helper"
require 'search_controller'

class SearchControllerTest < ActionController::TestCase

  def setup
    @controller = SearchController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(false)
    @response   = ActionController::TestResponse.new

    @environment = Environment.default
    @category = Category.create!(:name => 'my-category', :environment => @environment)

    domain = @environment.domains.first
    if !domain
      domain = Domain.create!(:name => "127.0.0.1")
      @environment.domains = [domain]
      @environment.save!
    end
    domain.google_maps_key = 'ENVIRONMENT_KEY'
    domain.save!

    @product_category = fast_create(ProductCategory)

    # By pass user validation on person creation
    user = mock()
    user.stubs(:id).returns(1)
    user.stubs(:valid?).returns(true)
    user.stubs(:email).returns('some@test.com')
    user.stubs(:save!).returns(true)
    user.stubs(:marked_for_destruction?).returns(false)
    Person.any_instance.stubs(:user).returns(user)
  end

  attr_reader :environment

  def create_article_with_optional_category(name, profile, category = nil)
    fast_create(Article, {:name => name, :profile_id => profile.id }, :search => true, :category => category)
  end

  def create_profile_with_optional_category(klass, name, category = nil, data = {})
    fast_create(klass, { :name => name }.merge(data), :search => true, :category => category)
  end

  should 'espape xss attack' do
    get 'index', :query => '<wslite>'
    assert_no_tag :tag => 'wslite'
  end

  should 'search only in specified types of content' do
    get :articles, :query => 'something not important'
    assert_equal [:articles], assigns(:searches).keys
  end

  should 'render success in search' do
    get :index, :query => 'something not important'
    assert_response :success
  end

  should 'search for articles' do
    person = fast_create(Person)
    art = create_article_with_optional_category('an article to be found', person)

    get 'articles', :query => 'article to be found'
    assert_includes assigns(:searches)[:articles][:results], art
  end

  should 'redirect contents to articles' do
    person = fast_create(Person)
    art = create_article_with_optional_category('an article to be found', person)

    get 'contents', :query => 'article found'
    # full description to avoid deprecation warning
    assert_redirected_to :controller => :search, :action => :articles, :query => 'article found'
  end

  # 'assets' outside any category
  should 'list articles in general' do
    person = fast_create(Person)

    art1 = create_article_with_optional_category('one article', person, @category)
    art2 = create_article_with_optional_category('two article', person, @category)

    get :articles

    assert_includes assigns(:searches)[:articles][:results], art1
    assert_includes assigns(:searches)[:articles][:results], art2
  end

  should 'find enterprises' do
    ent = create_profile_with_optional_category(Enterprise, 'teste')
    get :enterprises, :query => 'teste'
    assert_includes assigns(:searches)[:enterprises][:results], ent
  end

  should 'list enterprises in general' do
    ent1 = create_profile_with_optional_category(Enterprise, 'teste 1')
    ent2 = create_profile_with_optional_category(Enterprise, 'teste 2')

    get :enterprises
    assert_includes assigns(:searches)[:enterprises][:results], ent1
    assert_includes assigns(:searches)[:enterprises][:results], ent2
  end

  should 'search for people' do
    p1 = create_user('people_1').person;
    p1.name = 'a beautiful person';
    p1.save!
    get :people, :query => 'beautiful'
    assert_includes assigns(:searches)[:people][:results], p1
  end

  # 'assets' menu outside any category
  should 'list people in general' do
    Profile.delete_all

    p1 = create_user('test1').person
    p2 = create_user('test2').person

    get :people

    assert_equivalent [p2,p1], assigns(:searches)[:people][:results]
  end

  should 'find communities' do
    c1 = create_profile_with_optional_category(Community, 'a beautiful community')
    get :communities, :query => 'beautiful'
    assert_includes assigns(:searches)[:communities][:results], c1
  end

  # 'assets' menu outside any category
  should 'list communities in general' do
    c1 = create_profile_with_optional_category(Community, 'a beautiful community')
    c2 = create_profile_with_optional_category(Community, 'another beautiful community')

    get :communities
    assert_equivalent [c2, c1], assigns(:searches)[:communities][:results]
  end

  should 'search for products' do
    ent = create_profile_with_optional_category(Enterprise, 'teste')
    prod = ent.products.create!(:name => 'a beautiful product', :product_category => @product_category)
    get :products, :query => 'beautiful'
    assert_includes assigns(:searches)[:products][:results], prod
  end

  should 'include extra content supplied by plugins on product asset' do
    class Plugin1 < Noosfero::Plugin
      def asset_product_extras(product)
        proc {"<span id='plugin1'>This is Plugin1 speaking!</span>"}
      end
    end

    class Plugin2 < Noosfero::Plugin
      def asset_product_extras(product)
        proc {"<span id='plugin2'>This is Plugin2 speaking!</span>"}
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.to_s, Plugin2.to_s])

    enterprise = fast_create(Enterprise)
    prod_cat = fast_create(ProductCategory)
    product = fast_create(Product, {:profile_id => enterprise.id, :name => "produto1", :product_category_id => prod_cat.id}, :search => true)

    e = Environment.default
    e.enable_plugin(Plugin1.name)
    e.enable_plugin(Plugin2.name)

    get :products, :query => 'produto1'

    assert_tag :tag => 'span', :content => 'This is Plugin1 speaking!', :attributes => {:id => 'plugin1'}
    assert_tag :tag => 'span', :content => 'This is Plugin2 speaking!', :attributes => {:id => 'plugin2'}
  end

  should 'include extra properties of the product supplied by plugins' do
    class Plugin1 < Noosfero::Plugin
      def asset_product_properties(product)
        return { :name => _('Property1'), :content => proc { link_to(product.name, '/plugin1') } }
      end
    end
    class Plugin2 < Noosfero::Plugin
      def asset_product_properties(product)
        return { :name => _('Property2'), :content => proc { link_to(product.name, '/plugin2') } }
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.to_s, Plugin2.to_s])
    enterprise = fast_create(Enterprise)
    prod_cat = fast_create(ProductCategory)
    product = fast_create(Product, {:profile_id => enterprise.id, :name => "produto1", :product_category_id => prod_cat.id}, :search => true)

    environment = Environment.default
    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)

    get :products, :query => "produto1"

    assert_tag :tag => 'div', :content => /Property1/, :child => {:tag => 'a', :attributes => {:href => '/plugin1'}, :content => product.name}
    assert_tag :tag => 'div', :content => /Property2/, :child => {:tag => 'a', :attributes => {:href => '/plugin2'}, :content => product.name}
  end

  should 'paginate enterprise listing' do
    @controller.expects(:limit).returns(1).at_least_once
    ent1 = create_profile_with_optional_category(Enterprise, 'teste 1')
    ent2 = create_profile_with_optional_category(Enterprise, 'teste 2')

    get :enterprises, :page => '2'

    assert_equal 1, assigns(:searches)[:enterprises][:results].size
  end

  should 'display a given category' do
    get :category_index, :category_path => [ 'my-category' ]
    assert_equal @category, assigns(:category)
  end

  should 'not list "Search for ..." in category_index' do
    get :category_index, :category_path => [ 'my-category' ]
    assert_no_tag :content => /Search for ".*" in the whole site/
  end

  should 'not use design blocks' do
    get :index
    assert_no_tag :tag => 'div', :attributes => { :id => 'boxes', :class => 'boxes' }
  end

  should 'offer text box to enter a new search in general context' do
    get :index, :query => 'a sample search'
    assert_tag :tag => 'form', :attributes => { :action => '/search' }, :descendant => {
      :tag => 'input',
      :attributes => { :name => 'query', :value => 'a sample search' }
    }
  end

  should 'offer text box to enter a new seach in specific context' do
    get :index, :category_path => [ 'my-category'], :query => 'a sample search'
    assert_tag :tag => 'form', :attributes => { :action => '/search/index/my-category' }, :descendant => {
      :tag => 'input',
      :attributes => { :name => 'query', :value => 'a sample search' }
    }
  end

  should 'search in category hierachy' do
    parent = Category.create!(:name => 'Parent Category', :environment => Environment.default)
    child  = Category.create!(:name => 'Child Category', :environment => Environment.default, :parent_id => parent.id)

    p = create_profile_with_optional_category(Person, 'test_profile', child)

    get :category_index, :category_path => ['parent-category'], :query => 'test_profile'

    assert_includes assigns(:searches)[:people][:results], p
  end

  should 'render specific action when only one asset is enabled' do
    environment = Environment.default
    # article is not disabled
    [:enterprises, :people, :communities, :products, :events].select do |key, name|
      environment.enable('disable_asset_' + key.to_s)
    end
    environment.save!
    @controller.stubs(:environment).returns(environment)

    get :index, :query => 'something'

    assert assigns(:searches).has_key?(:articles)
    refute assigns(:searches).has_key?(:enterprises)
    refute assigns(:searches).has_key?(:people)
    refute assigns(:searches).has_key?(:communities)
    refute assigns(:searches).has_key?(:products)
    refute assigns(:searches).has_key?(:events)
  end

  should 'search all enabled assets in general search' do
    ent1 = create_profile_with_optional_category(Enterprise, 'test enterprise')
    prod_cat = create(ProductCategory, :name => 'pctest', :environment => Environment.default)
    prod = create(Product,:name => 'test product', :product_category => prod_cat, :enterprise => ent1)
    art = create(Article, :name => 'test article', :profile_id => fast_create(Person).id)
    per = create(Person, :name => 'test person', :identifier => 'test-person', :user_id => fast_create(User).id)
    com = create(Community, :name => 'test community')
    eve = create(Event, :name => 'test event', :profile_id => fast_create(Person).id)

    get :index, :query => 'test'

    [:articles, :enterprises, :people, :communities, :products, :events].select do |key, name|
      !assigns(:environment).enabled?('disable_asset_' + key.to_s)
    end.each do |asset|
      refute assigns(:searches)[asset][:results].empty?
    end
  end

  should 'display category image while in directory' do
    parent = Category.create!(:name => 'category1', :environment => Environment.default)
    cat = Category.create!(:name => 'category2', :environment => Environment.default, :parent_id => parent.id,
    :image_builder => {:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')}
    )

    process_delayed_job_queue
    get :category_index, :category_path => 'category1/category2', :query => 'teste'
    assert_tag :tag => 'img', :attributes => { :src => /rails_thumb\.png/ }
  end

  should 'search for events' do
    person = create_user('teste').person
    event = create_event(person, :name => 'an event to be found', :start_date => DateTime.now)

    get :events, :query => 'event to be found'

    assert_includes assigns(:searches)[:events][:results], event
  end

  should 'return events of the day' do
    person = create_user('someone').person
    ten_days_ago = DateTime.now - 10.day

    ev1 = create_event(person, :name => 'event 1', :category_ids => [@category.id],  :start_date => ten_days_ago)
    ev2 = create_event(person, :name => 'event 2', :category_ids => [@category.id],  :start_date => DateTime.now - 2.month)

    get :events, day: ten_days_ago.day, month: ten_days_ago.month, year: ten_days_ago.year
    assert_equal [ev1], assigns(:events)
  end

  should 'return events of the day with category' do
    person = create_user('someone').person
    ten_days_ago = DateTime.now - 10.day

    ev1 = create_event(person, :name => 'event 1', :start_date => ten_days_ago)
    ev1.categories = [@category]

    ev2 = create_event(person, :name => 'event 2', :start_date => ten_days_ago)

    get :events, day: ten_days_ago.day, month: ten_days_ago.month, year: ten_days_ago.year, category_path: @category.path.split('/')

    assert_equal [ev1], assigns(:events)
  end

  should 'return events of today when no date specified' do
    person = create_user('someone').person
    ev1 = create_event(person, :name => 'event 1', :category_ids => [@category.id],  :start_date => DateTime.now)
    ev2 = create_event(person, :name => 'event 2', :category_ids => [@category.id],  :start_date => DateTime.now - 2.month)

    get :events

    assert_equal [ev1], assigns(:events)
  end

  should 'show events for current month by default' do
    person = create_user('someone').person

    ev1 = create_event(person, :name => 'event 1', :category_ids => [@category.id],
      :start_date => DateTime.now + 2.month)
    ev2 = create_event(person, :name => 'event 2', :category_ids => [@category.id],
      :start_date => DateTime.now + 2.day)

    get :events

    assert_not_includes assigns(:searches)[:events][:results], ev1
    assert_includes assigns(:searches)[:events][:results], ev2
  end

  should 'list events for a given month' do
    person = create_user('testuser').person

    create_event(person, :name => 'upcoming event 1', :category_ids => [@category.id], :start_date => DateTime.new(2008, 1, 25))
    create_event(person, :name => 'upcoming event 2', :category_ids => [@category.id], :start_date => DateTime.new(2008, 4, 27))

    get :events, :year => '2008', :month => '1'

    assert_equal [ 'upcoming event 1' ], assigns(:searches)[:events][:results].map(&:name)
  end

  should 'see the events paginated' do
    person = create_user('testuser').person
    30.times do |i|
      create_event(person, :name => "Event #{i}", :start_date => DateTime.now)
    end
    get :events
    assert_equal 20, assigns(:events).size
  end

  %w[ people enterprises articles events communities products ].each do |asset|
    should "render asset-specific template when searching for #{asset}" do
      get "#{asset}"
      assert_template asset
    end
  end

  should 'display only within a product category when specified' do
    prod_cat = create(ProductCategory, :name => 'prod cat test', :environment => Environment.default)
    ent = create_profile_with_optional_category(Enterprise, 'test ent')

    p = create(Product, :product_category => prod_cat, :name => 'prod test 1', :enterprise => ent)

    get :products, :product_category => prod_cat.id

    assert_includes assigns(:searches)[:products][:results], p
  end

  should 'display properly in conjuntion with a category' do
    cat = create(Category, :name => 'cat', :environment => Environment.default)
    prod_cat1 = create(ProductCategory, :name => 'prod cat test 1', :environment => Environment.default)
    prod_cat2 = create(ProductCategory, :name => 'prod cat test 2', :environment => Environment.default, :parent => prod_cat1)
    ent = create_profile_with_optional_category(Enterprise, 'test ent', cat)

    product = create(Product, :product_category => prod_cat2, :name => 'prod test 1', :profile_id => ent.id)

    get :products, :category_path => cat.path.split('/'), :product_category => prod_cat1.id

    assert_includes assigns(:searches)[:products][:results], product
  end

  should 'provide calendar for events' do
    get :events
    assert_equal 0, assigns(:calendar).size % 7
  end

  should 'display current year/month by default as caption of current month' do
    DateTime.expects(:now).returns(DateTime.new(2008, 8, 1)).at_least_once

    get :events
    assert_tag :tag => 'table', :attributes => {:class => /current-month/}, :descendant => {:tag => 'caption', :content => /August 2008/}
  end

  should 'found TextileArticle in articles' do
    person = create_user('teste').person
    art = TextileArticle.create!(:name => 'an text_article article to be found', :profile => person)

    get 'articles', :query => 'article to be found'

    assert_includes assigns(:searches)[:articles][:results], art
  end

  should 'show link to article asset in the see all foot link of the articles block in the category page' do
    (1..SearchController::MULTIPLE_SEARCH_LIMIT+1).each do |i|
      a = create_user("test#{i}").person.articles.create!(:name => "article #{i} to be found")
      ArticleCategorization.add_category_to_article(@category, a)
    end

    get :category_index, :category_path => [ 'my-category' ]
    assert_tag :tag => 'div', :attributes => {:class => /search-results-articles/} , :descendant => {:tag => 'a', :attributes => { :href => '/search/articles/my-category'}}
  end

  should 'indicate more than the page limit for total_entries' do
    Enterprise.destroy_all
    ('1'..'20').each do |n|
      create_profile_with_optional_category(Enterprise, 'test ' + n)
    end

    get :index, :query => 'test'

    assert_equal 20, assigns(:searches)[:enterprises][:results].total_entries
  end

  should 'find products when enterprises has own hostname' do
    ent = create_profile_with_optional_category(Enterprise, 'teste')
    ent.domains << Domain.new(:name => 'testent.com'); ent.save!
    prod = ent.products.create!(:name => 'a beautiful product', :product_category => @product_category)
    get 'products', :query => 'beautiful'
    assert_includes assigns(:searches)[:products][:results], prod
  end

  should 'add script tag for google maps if searching products' do
    get 'products', :query => 'product', :display => 'map'

    assert_tag :tag => 'script', :attributes => { :src => 'http://maps.google.com/maps/api/js?sensor=true'}
  end

  should 'add script tag for google maps if searching enterprises' do
    ent = create_profile_with_optional_category(Enterprise, 'teste')
    get 'enterprises', :query => 'enterprise', :display => 'map'

    assert_tag :tag => 'script', :attributes => { :src => 'http://maps.google.com/maps/api/js?sensor=true'}
  end

  should 'show events of specific day' do
    person = create_user('anotheruser').person
    event = create_event(person, :name => 'Joao Birthday', :start_date => DateTime.new(2009, 10, 28))

    get :events_by_day, :year => 2009, :month => 10, :day => 28

    assert_tag :tag => 'a', :content => /Joao Birthday/
  end

  should 'ignore filter of events if category not exists' do
    person = create_user('anotheruser').person
    create_event(person, :name => 'Joao Birthday', :start_date => DateTime.new(2009, 10, 28), :category_ids => [@category.id])
    create_event(person, :name => 'Maria Birthday', :start_date => DateTime.new(2009, 10, 28))

    id_of_unexistent_category = Category.last.id + 10

    get :events_by_day, :year => 2009, :month => 10, :day => 28, :category_id => id_of_unexistent_category

    assert_tag :tag => 'a', :content => /Joao Birthday/
    assert_tag :tag => 'a', :content => /Maria Birthday/
  end

  should "paginate search of people in groups of #{SearchController::BLOCKS_SEARCH_LIMIT}" do
    Person.delete_all

    1.upto(SearchController::BLOCKS_SEARCH_LIMIT+3).map do |n|
      fast_create Person, {:name => 'Testing person'}
    end

    get :people
    assert_equal SearchController::BLOCKS_SEARCH_LIMIT+3, Person.count
    assert_equal SearchController::BLOCKS_SEARCH_LIMIT, assigns(:searches)[:people][:results].size
    assert_tag :a, '', :attributes => {:class => 'next_page'}
  end

  should 'list all community order by more recent one by default' do
    c1 = create(Community, :name => 'Testing community 1', :created_at => DateTime.now - 2)
    c2 = create(Community, :name => 'Testing community 2', :created_at => DateTime.now - 1)
    c3 = create(Community, :name => 'Testing community 3')

    get :communities
    assert_equal [c3,c2,c1] , assigns(:searches)[:communities][:results]
  end

  should "paginate search of communities in groups of #{SearchController::BLOCKS_SEARCH_LIMIT}" do
    1.upto(SearchController::BLOCKS_SEARCH_LIMIT+3).map do |n|
      fast_create Community, {:name => 'Testing community'}
    end

    get :communities
    assert_equal SearchController::BLOCKS_SEARCH_LIMIT+3, Community.count
    assert_equal SearchController::BLOCKS_SEARCH_LIMIT, assigns(:searches)[:communities][:results].size
    assert_tag :a, '', :attributes => {:class => 'next_page'}
  end

  should 'list all communities sort by more active' do
    person = fast_create(Person)
    c1 = create(Community, :name => 'Testing community 1')
    c2 = create(Community, :name => 'Testing community 2')
    c3 = create(Community, :name => 'Testing community 3')
    ActionTracker::Record.delete_all
    create(ActionTracker::Record, :target => c1, :user => person, :created_at => Time.now, :verb => 'leave_scrap')
    create(ActionTracker::Record, :target => c2, :user => person, :created_at => Time.now, :verb => 'leave_scrap')
    create(ActionTracker::Record, :target => c2, :user => person, :created_at => Time.now, :verb => 'leave_scrap')
    get :communities, :order => 'more_active'
    assert_equal [c2,c1,c3] , assigns(:searches)[:communities][:results]
  end

  should "only include visible people in more_recent filter" do
    # assuming that all filters behave the same!
    p1 = fast_create(Person, :visible => false)
    get :people, :order => 'more_recent'
    assert_not_includes assigns(:searches)[:people][:results], p1
  end

  should "only include visible communities in more_recent filter" do
    # assuming that all filters behave the same!
    p1 = fast_create(Community, :visible => false)
    get :communities, :order=> 'more_recent'
    assert_not_includes assigns(:searches)[:communities][:results], p1
  end

  should 'keep old urls working' do
    get :assets, :asset => 'articles'
    assert_redirected_to :controller => :search, :action => :articles
    get :assets, :asset => 'people'
    assert_redirected_to :controller => :search, :action => :people
    get :assets, :asset => 'communities'
    assert_redirected_to :controller => :search, :action => :communities
    get :assets, :asset => 'products'
    assert_redirected_to :controller => :search, :action => :products
    get :assets, :asset => 'enterprises'
    assert_redirected_to :controller => :search, :action => :enterprises
    get :assets, :asset => 'events'
    assert_redirected_to :controller => :search, :action => :events
  end

  should 'show tag cloud' do
    @controller.stubs(:is_cache_expired?).returns(true)
    a = create(Article, :name => 'my article', :profile_id => fast_create(Person).id)
    a.tag_list = ['one', 'two']
    a.save_tags

    get :tags

    assert assigns(:tags)["two"] = 1
    assert assigns(:tags)["one"] = 1
  end

  should 'show tagged content' do
    @controller.stubs(:is_cache_expired?).returns(true)
    a = Article.create!(:name => 'my article', :profile => fast_create(Person))
    a2 = Article.create!(:name => 'my article 2', :profile => fast_create(Person))
    a.tag_list = ['one', 'two']
    a2.tag_list = ['two', 'three']
    a.save_tags
    a2.save_tags

    get :tag, :tag => 'two'

    assert_equivalent [a, a2], assigns(:searches)[:tag][:results]

    get :tag, :tag => 'one'

    assert_equivalent [a], assigns(:searches)[:tag][:results]
  end

  should 'not show assets from other environments' do
    other_env = Environment.create!(:name => 'Another environment')
    p1 = create(Person, :name => 'Hildebrando', :identifier => 'hild', :user_id => fast_create(User).id, :environment_id => other_env.id)
    p2 = create(Person, :name => 'Adamastor', :identifier => 'adam', :user_id => fast_create(User).id)
    art1 = create(Article, :name => 'my article', :profile_id => p1.id)
    art2 = create(Article, :name => 'my article', :profile_id => p2.id)

    get :articles, :query => 'my article'

    assert_equal [art2], assigns(:searches)[:articles][:results]
  end

  should 'order articles by more recent' do
    Article.destroy_all
    art1 = create(Article, :name => 'review C', :profile_id => fast_create(Person).id, :created_at => Time.now-1.days)
    art2 = create(Article, :name => 'review A', :profile_id => fast_create(Person).id, :created_at => Time.now)
    art3 = create(Article, :name => 'review B', :profile_id => fast_create(Person).id, :created_at => Time.now-2.days)

    get :articles, :order=> :more_recent

    assert_equal [art2, art1, art3], assigns(:searches)[:articles][:results]
  end

  should 'add highlighted CSS class around a highlighted product' do
    enterprise = fast_create(Enterprise)
    product = create(Product, :name => 'Enter Sandman', :profile_id => enterprise.id, :product_category_id => @product_category.id, :highlighted => true)
    get :products
    assert_tag :tag => 'li', :attributes => { :class => 'search-product-item highlighted' }, :content => /Enter Sandman/
  end

  should 'do not add highlighted CSS class around an ordinary product' do
    enterprise = fast_create(Enterprise)
    product = create(Product, :name => 'Holier Than Thou', :profile_id => enterprise.id, :product_category_id => @product_category.id, :highlighted => false)
    get :products
    assert_no_tag :tag => 'li', :attributes => { :class => 'search-product-item highlighted' }, :content => /Holier Than Thou/
  end

  should 'get search suggestions on json' do
    st1 = 'universe A'
    st2 = 'universe B'
    @controller.stubs(:find_suggestions).with('universe', Environment.default, 'communities').returns([st1, st2])
    get :suggestions, :term => 'universe', :asset => 'communities'
    assert_equal [st1,st2].to_json, response.body
  end

  should 'normalize search term for suggestions' do
    st1 = 'UnIvErSe A'
    st2 = 'uNiVeRsE B'
    @controller.stubs(:find_suggestions).with('universe', Environment.default, 'communities').returns([st1, st2])
    get :suggestions, :term => 'UNIveRSE', :asset => 'communities'
    assert_equal [st1,st2].to_json, response.body
  end

  should 'templates variable be an hash in articles asset' do
    get :articles
    assert assigns(:templates).kind_of?(Hash)
  end

  should 'not load people templates in articles asset' do
    t1 = fast_create(Person, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Person, :is_template => true, :environment_id => environment.id)
    get :articles
    assert_nil assigns(:templates)[:people]
  end

  should 'not load communities templates in articles asset' do
    t1 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    get :articles
    assert_nil assigns(:templates)[:communities]
  end

  should 'not load enterprises templates in articles asset' do
    t1 = fast_create(Enterprise, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Enterprise, :is_template => true, :environment_id => environment.id)
    get :articles
    assert_nil assigns(:templates)[:enterprises]
  end

  should 'templates variable be equals to people templates in people assert' do
    t1 = fast_create(Person, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Person, :is_template => true, :environment_id => environment.id)
    get :people

    assert_equivalent [t1,t2], assigns(:templates)[:people]
  end

  should 'not load communities templates in people asset' do
    t1 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    get :people
    assert_nil assigns(:templates)[:communities]
  end

  should 'not load enterprises templates in people asset' do
    t1 = fast_create(Enterprise, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Enterprise, :is_template => true, :environment_id => environment.id)
    get :people
    assert_nil assigns(:templates)[:enterprises]
  end

  should 'templates variable be equals to communities templates in communities assert' do
    t1 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    get :communities

    assert_equivalent [t1,t2], assigns(:templates)[:communities]
  end

  should 'not load people templates in communities asset' do
    t1 = fast_create(Person, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Person, :is_template => true, :environment_id => environment.id)
    get :communities
    assert_nil assigns(:templates)[:people]
  end

  should 'not load enterprises templates in communities asset' do
    t1 = fast_create(Enterprise, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Enterprise, :is_template => true, :environment_id => environment.id)
    get :communities
    assert_nil assigns(:templates)[:enterprises]
  end

  should 'templates variable be equals to enterprises templates in enterprises assert' do
    t1 = fast_create(Enterprise, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Enterprise, :is_template => true, :environment_id => environment.id)
    get :enterprises

    assert_equivalent [t1,t2], assigns(:templates)[:enterprises]
  end

  should 'not load communities templates in enterprises asset' do
    t1 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    get :enterprises
    assert_nil assigns(:templates)[:communities]
  end

  should 'not load people templates in enterprises asset' do
    t1 = fast_create(Person, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Person, :is_template => true, :environment_id => environment.id)
    get :enterprises
    assert_nil assigns(:templates)[:people]
  end

  should 'list all community of on specific template' do
    t1 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    c1 = fast_create(Community, :template_id => t1.id, :name => 'Testing community 1', :created_at => DateTime.now - 2)
    c2 = fast_create(Community, :template_id => t2.id, :name => 'Testing community 2', :created_at => DateTime.now - 1)
    c3 = fast_create(Community, :template_id => t1.id, :name => 'Testing community 3')
    c4 = fast_create(Community, :name => 'Testing community 3')

    get :communities, :template_id => t1.id
    assert_equivalent [c1,c3] , assigns(:searches)[:communities][:results]
  end

  should 'list all communities of no template is passed' do
    t1 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    t2 = fast_create(Community, :is_template => true, :environment_id => environment.id)
    c1 = create(Community, :template_id => t1.id, :name => 'Testing community 1', :created_at => DateTime.now - 2)
    c2 = create(Community, :template_id => t2.id, :name => 'Testing community 2', :created_at => DateTime.now - 1)
    c3 = create(Community, :template_id => t1.id, :name => 'Testing community 3')
    c4 = create(Community, :name => 'Testing community 3')

    get :communities, :template_id => nil
    assert_equivalent [t1,t2,c1,c2,c3,c4] , assigns(:searches)[:communities][:results]
  end

  protected

  def create_event(profile, options)
    ev = build(Event, { :name => 'some event', :start_date => DateTime.new(2008,1,1) }.merge(options))
    ev.profile = profile
    ev.save!
    ev
  end

end
