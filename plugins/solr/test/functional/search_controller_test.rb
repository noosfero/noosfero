require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../../lib/ext/facets_browse'

# Re-raise errors caught by the controller.
class SearchController; def rescue_action(e) raise e end; end

class SearchControllerTest < ActionController::TestCase

  def setup
    TestSolr.enable
    p1 = File.join(RAILS_ROOT, 'app', 'views')
    p2 = File.join(File.dirname(__FILE__) + '/../../views')
    SearchController.append_view_path([p1,p2])
    @controller = SearchController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(false)
    @response   = ActionController::TestResponse.new

    @category = Category.create!(:name => 'my category', :environment => Environment.default)

    env = Environment.default
    domain = env.domains.first
    if !domain
      domain = Domain.create!(:name => "127.0.0.1")
      env.domains = [domain]
      env.save!
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
    Person.any_instance.stubs(:user).returns(user)

    env.enable_plugin(SolrPlugin)
  end

  should 'get facets with articles search results' do
		cat1 = fast_create(Category, :name => 'cat1')
		cat2 = fast_create(Category, :name => 'cat2')
    person = fast_create(Person)
    art = create_article_with_optional_category('an article to be found', person)
		art.add_category cat1, false
		art.add_category cat2, true
		art.save!

    get 'articles', :query => 'article found'
		assert !assigns(:searches)[:articles][:facets].blank?
		assert assigns(:searches)[:articles][:facets]['facet_fields']['solr_plugin_f_type_facet'][0][0] == 'Article'
		assert assigns(:searches)[:articles][:facets]['facet_fields']['solr_plugin_f_profile_type_facet'][0][0] == 'Person'
		assert assigns(:searches)[:articles][:facets]['facet_fields']['solr_plugin_f_category_facet'][0][0] == 'cat1'
		assert assigns(:searches)[:articles][:facets]['facet_fields']['solr_plugin_f_category_facet'][1][0] == 'cat2'
  end

  should 'get facets with people search results' do
    state = fast_create(State, :name => 'Acre', :acronym => 'AC')
    city = fast_create(City, :name => 'Rio Branco', :parent_id => state.id)
    person = Person.create!(:name => 'Hildebrando', :identifier => 'hild', :user_id => fast_create(User).id, :region_id => city.id)
    cat1 = fast_create(Category, :name => 'cat1')
    cat2 = fast_create(Category, :name => 'cat2')
    person.add_category cat1
    person.add_category cat2

    get 'people', :query => 'Hildebrando'

    assert !assigns(:searches)[:people][:facets].blank?
    assert assigns(:searches)[:people][:facets]['facet_fields']['solr_plugin_f_region_facet'][0][0] == city.id.to_s

    categories_facet = assigns(:searches)[:people][:facets]['facet_fields']['solr_plugin_f_categories_facet']
    assert_equal 2, categories_facet.count
    assert_equivalent [cat1.id.to_s, cat2.id.to_s], [categories_facet[0][0], categories_facet[1][0]]
  end

  should 'get facets with products search results' do
		state = fast_create(State, :name => 'Acre', :acronym => 'AC')
		city = fast_create(City, :name => 'Rio Branco', :parent_id => state.id)
		ent = fast_create(Enterprise, :region_id => city.id)
    prod = Product.create!(:name => 'Sound System', :profile_id => ent.id, :product_category_id => @product_category.id)
		qualifier1 = fast_create(Qualifier)
		qualifier2 = fast_create(Qualifier)
		prod.qualifiers_list = [[qualifier1.id, 0], [qualifier2.id, 0]]
		prod.qualifiers.reload
		prod.save!

    get 'products', :query => 'Sound'
		assert !assigns(:searches)[:products][:facets].blank?
		assert assigns(:searches)[:products][:facets]['facet_fields']['solr_plugin_f_category_facet'][0][0] == @product_category.name
		assert assigns(:searches)[:products][:facets]['facet_fields']['solr_plugin_f_region_facet'][0][0] == city.id.to_s
		assert assigns(:searches)[:products][:facets]['facet_fields']['solr_plugin_f_qualifier_facet'][0][0] == "#{qualifier1.id} 0"
		assert assigns(:searches)[:products][:facets]['facet_fields']['solr_plugin_f_qualifier_facet'][1][0] == "#{qualifier2.id} 0"
  end

  # 'assets' menu outside any category
  should 'list products in general without geosearch' do
    Profile.delete_all
		SearchController.stubs(:logged_in?).returns(false)

    ent1 = create_profile_with_optional_category(Enterprise, 'teste1')
    ent2 = create_profile_with_optional_category(Enterprise, 'teste2')
    prod1 = ent1.products.create!(:name => 'a beautiful product', :product_category => @product_category)
    prod2 = ent2.products.create!(:name => 'another beautiful product', :product_category => @product_category)

    get :products
    assert_equivalent [prod2, prod1], assigns(:searches)[:products][:results].docs
		assert_match 'Highlights', @response.body
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

  should 'find enterprise by product category' do
    ent1 = create_profile_with_optional_category(Enterprise, 'test1')
    prod_cat = ProductCategory.create!(:name => 'pctest', :environment => Environment.default)
    prod = ent1.products.create!(:name => 'teste', :product_category => prod_cat)

    ent2 = create_profile_with_optional_category(Enterprise, 'test2')

    get :index, :query => prod_cat.name

    assert_includes assigns(:searches)[:enterprises][:results], ent1
    assert_not_includes assigns(:searches)[:enterprises][:results], ent2
  end

  should 'show only results in general search' do
    ent1 = create_profile_with_optional_category(Enterprise, 'test1')
    prod_cat = ProductCategory.create!(:name => 'pctest', :environment => Environment.default)
    prod = ent1.products.create!(:name => 'teste', :product_category => prod_cat)

    ent2 = create_profile_with_optional_category(Enterprise, 'test2')

    get :index, :query => prod_cat.name

		assert assigns(:facets).blank?
		assert assigns(:searches)[:enterprises][:facets].blank?
		assert assigns(:searches)[:products][:facets].blank?
	end

	# Testing random sequences always have a small chance of failing
	should 'randomize product display in empty search' do
    prod_cat = ProductCategory.create!(:name => 'prod cat test', :environment => Environment.default)
    ent = create_profile_with_optional_category(Enterprise, 'test enterprise')
    (1..SearchController::LIST_SEARCH_LIMIT+5).each do |n|
      fast_create(Product, {:name => "produto #{n}", :profile_id => ent.id, :product_category_id => prod_cat.id}, :search => true)
    end

    get :products
    result1 = assigns(:searches)[:products][:results].map(&:id)

    (1..10).each do |n|
      get :products
    end
    result2 = assigns(:searches)[:products][:results].map(&:id)

    assert_not_equal result1, result2
	end

	should 'remove far products by geolocalization empty logged search' do
    user = create_user('a_logged_user')
    # trigger geosearch
    user.person.lat = '1.0'
    user.person.lng = '1.0'
    SearchController.any_instance.stubs(:logged_in?).returns(true)
    SearchController.any_instance.stubs(:current_user).returns(user)

    cat = fast_create(ProductCategory)
    ent1 = Enterprise.create!(:name => 'ent1', :identifier => 'ent1', :lat => '1.3', :lng => '1.3')
    prod1 = Product.create!(:name => 'produto 1', :profile_id => ent1.id, :product_category_id => cat.id)
    ent2 = Enterprise.create!(:name => 'ent2', :identifier => 'ent2', :lat => '2.0', :lng => '2.0')
    prod2 = Product.create!(:name => 'produto 2', :profile_id => ent2.id, :product_category_id => cat.id)
    ent3 = Enterprise.create!(:name => 'ent3', :identifier => 'ent3', :lat => '1.6', :lng => '1.6')
    prod3 = Product.create!(:name => 'produto 3', :profile_id => ent3.id, :product_category_id => cat.id)
    ent4 = Enterprise.create!(:name => 'ent4', :identifier => 'ent4', :lat => '10', :lng => '10')
    prod4 = Product.create!(:name => 'produto 4', :profile_id => ent4.id, :product_category_id => cat.id)

    get :products
    assert_equivalent [prod1, prod3, prod2], assigns(:searches)[:products][:results].docs
	end

	should 'browse facets when query is not empty' do
		get :articles, :query => 'something'
		get :facets_browse, :asset_key => 'articles', :facet_id => 'solr_plugin_f_type'
		assert_equal assigns(:facet)[:id], 'solr_plugin_f_type'
		get :products, :query => 'something'
		get :facets_browse, :asset_key => 'products', :facet_id => 'solr_plugin_f_category'
		assert_equal assigns(:facet)[:id], 'solr_plugin_f_category'
		get :people, :query => 'something'
		get :facets_browse, :asset_key => 'people', :facet_id => 'solr_plugin_f_region'
		assert_equal assigns(:facet)[:id], 'solr_plugin_f_region'
	end

	should 'raise exception when facet is invalid' do
		get :articles, :query => 'something'
		assert_raise RuntimeError do
			get :facets_browse, :asset_key => 'articles', :facet_id => 'solr_plugin_fwhatever'
		end
	end

  should 'order product results by more recent when requested' do
		ent = fast_create(Enterprise)
    prod1 = Product.create!(:name => 'product 1', :profile_id => ent.id, :product_category_id => @product_category.id)
    prod2 = Product.create!(:name => 'product 2', :profile_id => ent.id, :product_category_id => @product_category.id)
    prod3 = Product.create!(:name => 'product 3', :profile_id => ent.id, :product_category_id => @product_category.id)

    # change others attrs will make updated_at = Time.now for all
    Product.record_timestamps = false
    prod3.update_attribute :updated_at, Time.now-2.days
    prod1.update_attribute :updated_at, Time.now-1.days
    prod2.update_attribute :updated_at, Time.now
    Product.record_timestamps = true

    get :products, :query => 'product', :order_by => :more_recent

    assert_equal [prod2, prod1, prod3], assigns(:searches)[:products][:results].docs
  end

  should 'only list products from enabled enterprises' do
		ent1 = fast_create(Enterprise, :enabled => true)
		ent2 = fast_create(Enterprise, :enabled => false)
    prod1 = Product.create!(:name => 'product 1', :profile_id => ent1.id, :product_category_id => @product_category.id)
    prod2 = Product.create!(:name => 'product 2', :profile_id => ent2.id, :product_category_id => @product_category.id)

    get :products, :query => 'product'

    assert_includes assigns(:searches)[:products][:results], prod1
    assert_not_includes assigns(:searches)[:products][:results], prod2
  end

  should 'order product results by name when requested' do
		ent = fast_create(Enterprise)
    prod1 = Product.create!(:name => 'product 1', :profile_id => ent.id, :product_category_id => @product_category.id)
    prod2 = Product.create!(:name => 'product 2', :profile_id => ent.id, :product_category_id => @product_category.id)
    prod3 = Product.create!(:name => 'product 3', :profile_id => ent.id, :product_category_id => @product_category.id)

    prod3.update_attribute :name, 'product A'
    prod2.update_attribute :name, 'product B'
    prod1.update_attribute :name, 'product C'

    get :products, :query => 'product', :order_by => :name

    assert_equal [prod3, prod2, prod1], assigns(:searches)[:products][:results].docs
  end

	should 'order product results by closest when requested' do
    user = create_user('a_logged_user')
		user.person.lat = '1.0'
		user.person.lng = '1.0'
    # trigger geosearch
		SearchController.any_instance.stubs(:logged_in?).returns(true)
		SearchController.any_instance.stubs(:current_user).returns(user)

		cat = fast_create(ProductCategory)
		ent1 = Enterprise.create!(:name => 'ent1', :identifier => 'ent1', :lat => '-5.0', :lng => '-5.0')
    prod1 = Product.create!(:name => 'product 1', :profile_id => ent1.id, :product_category_id => cat.id)
		ent2 = Enterprise.create!(:name => 'ent2', :identifier => 'ent2', :lat => '2.0', :lng => '2.0')
    prod2 = Product.create!(:name => 'product 2', :profile_id => ent2.id, :product_category_id => cat.id)
		ent3 = Enterprise.create!(:name => 'ent3', :identifier => 'ent3', :lat => '10.0', :lng => '10.0')
    prod3 = Product.create!(:name => 'product 3', :profile_id => ent3.id, :product_category_id => cat.id)

		get :products, :query => 'product', :order_by => :closest
		assert_equal [prod2, prod1, prod3], assigns(:searches)[:products][:results].docs
	end


  should 'order events by name when requested' do
    person = create_user('someone').person
    ev1 = create_event(person, :name => 'party B', :category_ids => [@category.id],	:start_date => Date.today - 1.day)
    ev2 = create_event(person, :name => 'party A', :category_ids => [@category.id],	:start_date => Date.today - 2.days)

    get :events, :query => 'party', :order_by => :name

    assert_equal [ev2, ev1], assigns(:searches)[:events][:results].docs
  end

  should 'order articles by name when requested' do
		art1 = Article.create!(:name => 'review C', :profile_id => fast_create(Person).id)
		art2 = Article.create!(:name => 'review A', :profile_id => fast_create(Person).id)
		art3 = Article.create!(:name => 'review B', :profile_id => fast_create(Person).id)

    get :articles, :query => 'review', :order_by => :name

    assert_equal [art2, art3, art1], assigns(:searches)[:articles][:results].docs
  end

  should 'order enterprise results by name when requested' do
		ent1 = Enterprise.create!(:name => 'Company B', :identifier => 'com_b')
		ent2 = Enterprise.create!(:name => 'Company A', :identifier => 'com_a')
		ent3 = Enterprise.create!(:name => 'Company C', :identifier => 'com_c')

    get :enterprises, :query => 'Company', :order_by => :name

    assert_equal [ent2, ent1, ent3], assigns(:searches)[:enterprises][:results].docs
  end

  should 'order people results by name when requested' do
		person1 = Person.create!(:name => 'Deodárbio Silva', :identifier => 'deod', :user_id => fast_create(User).id)
		person2 = Person.create!(:name => 'Glislange Silva', :identifier => 'glis', :user_id => fast_create(User).id)
		person3 = Person.create!(:name => 'Ausêncio Silva', :identifier => 'ause', :user_id => fast_create(User).id)

    get :people, :query => 'Silva', :order_by => :name

    assert_equal [person3, person1, person2], assigns(:searches)[:people][:results].docs
  end

  should 'order community results by name when requested' do
		com1 = Community.create!(:name => 'Yellow Group')
		com2 = Community.create!(:name => 'Red Group')
		com3 = Community.create!(:name => 'Green Group')

    get :communities, :query => 'Group', :order_by => :name

    assert_equal [com3, com2, com1], assigns(:searches)[:communities][:results].docs
  end

  should 'raise error when requested to order by unknown filter' do
		com1 = Community.create!(:name => 'Yellow Group')
		com2 = Community.create!(:name => 'Red Group')
		com3 = Community.create!(:name => 'Green Group')

    assert_raise RuntimeError do
      get :communities, :query => 'Group', :order_by => :something
    end
  end

  protected

  def create_article_with_optional_category(name, profile, category = nil)
    fast_create(Article, {:name => name, :profile_id => profile.id }, :search => true, :category => category)
  end

  def create_profile_with_optional_category(klass, name, category = nil, data = {})
    fast_create(klass, { :name => name }.merge(data), :search => true, :category => category)
  end

  def create_event(profile, options)
    ev = Event.new({ :name => 'some event', :start_date => Date.new(2008,1,1) }.merge(options))
    ev.profile = profile
    ev.save!
    ev
  end

end
