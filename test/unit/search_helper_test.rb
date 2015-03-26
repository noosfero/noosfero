require_relative "../test_helper"

class SearchHelperTest < ActiveSupport::TestCase

  include SearchHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormTagHelper


  should 'return whether on a multiple search' do
    stubs(:params).returns({:action => 'index', :display => 'map'})
    @results = {:articles => [1,2], :products => [1,2]}
    assert multiple_search?

    stubs(:params).returns({:action => 'products', :display => 'map'})
    @results = {:products => [1,2]}
    assert !multiple_search?
  end

  should 'return whether on a map search' do
    stubs(:params).returns({:action => 'index', :display => 'map'})
    @results = {:articles => [1,2], :products => [1,2]}
    @query = ''
    assert !map_search?

    stubs(:params).returns({:action => 'products', :display => 'map'})
    @results = {:products => [1,2]}
    @query = 'test'
    assert map_search?
  end

  should 'display search page title' do
    title = 'page_title'
    assert_equal search_page_title(title), '<h1>page_title</h1>' 
  end

  should 'display search page title with category name' do
    title = 'page_title'
    category = mock
    category.stubs(:name).returns('category_name')
    assert_equal '<h1>page_title - <small>category_name</small></h1>',
      search_page_title(title, category)
  end

  should 'display category context' do
    stubs(:params).returns({:action => 'action'})
    category = mock
    category.stubs(:full_name).returns('category_full_name')
    expects('link_to').returns('link_to_result').once
    expects('content_tag').with('div', 'category_full_name, link_to_result', anything)
    category_context(category, {})
  end

  should 'display results without map' do
    stubs(:params).returns({:display => ''})
    expects('render').with({:partial => 'display_results'}).returns('render_return')
    expects('content_tag').with('div', 'render_return', :class => 'map-or-list-search-results list')
    display_results
  end

  should 'display results with map' do
    stubs(:params).returns({:display => 'map'})
    @query = 'test'
    @searches = {:products => {:results => [1,2]}}
    expects('render').with({:partial => 'google_maps'}).returns('render_return')
    expects('content_tag').with('div', 'render_return', :class => 'map-or-list-search-results map')
    display_results(@searches, :products)
  end

  should 'return full city name with state' do
    state = mock
    state.stubs(:kind_of?).with(State).returns(true)
    state.stubs(:acronym).returns('CE')
    city = mock
    city.stubs(:parent).returns(state)
    city.stubs(:kind_of?).with(City).returns(true)
    city.stubs(:name).returns('Jijoca de Jericoacoara')
	assert_equal 'Jijoca de Jericoacoara, CE', city_with_state(city)
  end

  should 'not return city_with_state when city is nil' do
	assert_nil city_with_state nil
  end

  should 'not return city_with_state when parameter is not a City' do
    city = mock
    city.stubs(:kind_of?).with(City).returns(false)
	assert_nil city_with_state city
  end

  should 'return city name when parent is not defined' do
    city = mock
    city.stubs(:kind_of?).with(City).returns(true)
    city.stubs(:parent).returns(nil)
    city.stubs(:name).returns('Feliz Deserto')
	assert_equal 'Feliz Deserto', city_with_state(city)
  end

  should 'return city name when parent is not a State' do
    state = mock
    state.stubs(:kind_of?).with(State).returns(false)
    city = mock
    city.stubs(:kind_of?).with(City).returns(true)
    city.stubs(:parent).returns(state)
    city.stubs(:name).returns('Feliz Deserto')
	assert_equal 'Feliz Deserto', city_with_state(city)
  end

  should 'return city name when parent has no acronym' do
    state = mock
    state.stubs(:kind_of?).with(State).returns(true)
    state.stubs(:acronym).returns(nil)
    city = mock
    city.stubs(:kind_of?).with(City).returns(true)
    city.stubs(:parent).returns(state)
    city.stubs(:name).returns('Feliz Deserto')
	assert_equal 'Feliz Deserto', city_with_state(city)
  end
    
  should 'return asset class from string' do
    asset_names = ['products', 'events', 'articles', 'enterprises', 'people', 'communities']
    asset_classes = [Product, Event, Article, Enterprise, Person, Community]
    asset_names.each_index do |i|
      assert_equal asset_classes[i], asset_class(asset_names[i])
    end
  end

  should 'return an empty string in assets_submenu for articles assets' do
    @templates = {}
    assert_equal '', assets_submenu(:articles)
    @templates = {:articles => nil}
    assert_equal '', assets_submenu(:articles)
  end

  should 'return an empty string in assets_submenu for people asset without template' do
    @templates = {:people => nil}
    assert_equal '', assets_submenu(:people)

    @templates = {:people => []}
    assert_equal '', assets_submenu(:people)
  end

  should 'return an empty string in assets_submenu for people asset with only one template' do
    t = fast_create(Person, :is_template => true)
    @templates = {:people => [t]}
    assert_equal '', assets_submenu(:people)
  end

  should 'return a select of templates for people asset with more then one template' do
    t1 = fast_create(Person, :is_template => true)
    t2 = fast_create(Person, :is_template => true)
    @templates = {:people => [t1,t2]}
    SearchHelperTest.any_instance.stubs(:params).returns({})
    assert_match /select/, assets_submenu(:people)
    assert_match /#{t1.name}/, assets_submenu(:people)
    assert_match /#{t2.name}/, assets_submenu(:people)
  end

  should 'return an empty string in assets_submenu for communities asset without template' do
    @templates = {:communities => nil}
    assert_equal '', assets_submenu(:communities)

    @templates = {:communities => []}
    assert_equal '', assets_submenu(:communities)
  end

  should 'return an empty string in assets_submenu for communities asset with only one template' do
    t = fast_create(Community, :is_template => true)
    @templates = {:communities => [t]}
    assert_equal '', assets_submenu(:communities)
  end

  should 'return a select of templates for communities asset with more then one template' do
    t1 = fast_create(Community, :is_template => true)
    t2 = fast_create(Community, :is_template => true)
    @templates = {:communities => [t1,t2]}
    SearchHelperTest.any_instance.stubs(:params).returns({})
    assert_match /select/, assets_submenu(:communities)
    assert_match /#{t1.name}/, assets_submenu(:communities)
    assert_match /#{t2.name}/, assets_submenu(:communities)
  end

  should 'return an empty string in assets_submenu for enterprises asset without template' do
    @templates = {:enterprises => nil}
    assert_equal '', assets_submenu(:enterprises)

    @templates = {:enterprises => []}
    assert_equal '', assets_submenu(:enterprises)
  end

  should 'return an empty string in assets_submenu for enterprises asset with only one template' do
    t = fast_create(Enterprise, :is_template => true)
    @templates = {:enterprises => [t]}
    assert_equal '', assets_submenu(:enterprises)
  end

  should 'return a select of templates for enterprises asset with more then one template' do
    t1 = fast_create(Enterprise, :is_template => true)
    t2 = fast_create(Enterprise, :is_template => true)
    @templates = {:enterprises => [t1,t2]}
    SearchHelperTest.any_instance.stubs(:params).returns({})
    assert_match /select/, assets_submenu(:enterprises)
    assert_match /#{t1.name}/, assets_submenu(:enterprises)
    assert_match /#{t2.name}/, assets_submenu(:enterprises)
  end


end
