require File.dirname(__FILE__) + '/../test_helper'

class SearchHelperTest < ActiveSupport::TestCase

  include SearchHelper

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
    assert_equal '<h1>page_title<small>category_name</small></h1>',
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
    @results = {:products => [1,2]}
    expects('render').with({:partial => 'google_maps'}).returns('render_return')
    expects('content_tag').with('div', 'render_return', :class => 'map-or-list-search-results map')
    display_results true
  end

  should 'show display_list button when in map view' do
    stubs(:params).returns({:display => 'map'})
    expects(:button).with(:search, 'Display in list', {:display => 'list'}, anything)
    display_map_list_button
  end

  should 'show display_map button when in list view' do
    stubs(:params).returns({:display => ''})
    expects(:button).with(:search, 'Display in map', {:display => 'map'}, anything)
    display_map_list_button
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

  should 'display facets menu' do
    expects(:asset_class).with('asset')
    expects(:render).with(:partial => 'facets_menu')
    facets_menu 'asset', nil
  end

  should 'display facets_unselect menu' do
    expects(:asset_class).with('asset')
    expects(:render).with(:partial => 'facets_unselect_menu')
    facets_unselect_menu 'asset'
  end

  should 'display facets javascript' do
    expects(:text_field_tag).returns('<text_field_tag_return>')
    expects(:javascript_tag).with(regexp_matches(/id.*[\'array_item\'].*json_message/m)).returns(
      '<javascript_tag_return>')
    stubs(:jquery_token_input_messages_json).returns('json_message')
    assert_equal '<text_field_tag_return><javascript_tag_return>', 
      facet_javascript('id', '', ['array_item'])
  end

  should 'display empty array in facets javascript if array is nil' do
    expects(:text_field_tag).returns('<text_field_tag_return>')
    expects(:javascript_tag).with(regexp_matches(/id.*\[\].*json_message/m)).returns(
      '<javascript_tag_return>')
    stubs(:jquery_token_input_messages_json).returns('json_message')
    assert_equal '<text_field_tag_return><javascript_tag_return>', 
      facet_javascript('id', '', [])
  end

  should 'return html code for facet link' do
    facet = {
      :solr_field => 'facet_solr_field', 
      :label_id => 'facet_label_id'
    }
    params = {}
    value = 'facet_value'
    label = 'facet_label'
    count = 1

    expected_url = {:facet => {'facet_solr_field' => { 'facet_label_id' => ['facet_value']}}}

    expects(:link_to).with('facet_label', expected_url, anything).returns('<link_to_result>')
    stubs(:content_tag).with(anything, '', anything).returns('<content_tag_extra>')
    stubs(:content_tag).with(anything, ' (1)', anything).returns('<content_tag_count>')
    stubs(:content_tag).with(anything, '<link_to_result><content_tag_extra><content_tag_count>', anything).returns('<content_tag_final_result>')

    assert_equal '<content_tag_final_result>', 
      facet_link_html(facet, params, value, label, count)
  end

  should 'return html code for facet link with extra label' do
    facet = {
      :solr_field => 'facet_solr_field', 
      :label_id => 'facet_label_id'
    }
    params = {}
    value = 'facet_value'
    label = ['facet_label', 'facet_extra']
    count = 1

    expected_url = {:facet => {'facet_solr_field' => { 'facet_label_id' => ['facet_value']}}}

    expects(:link_to).with('facet_label', expected_url, anything).returns('<link_to_result>')
    stubs(:content_tag).with(anything, 'facet_extra', anything).returns('<content_tag_extra>')
    stubs(:content_tag).with(anything, ' (1)', anything).returns('<content_tag_count>')
    stubs(:content_tag).with(anything, '<link_to_result><content_tag_extra><content_tag_count>', anything).returns('<content_tag_final_result>')

    assert_equal '<content_tag_final_result>', 
      facet_link_html(facet, params, value, label, count)
  end

  should 'return html code for selected facet link' do
    facet = {
      :solr_field => 'facet_solr_field' 
    }
    params = {:facet => {'facet_solr_field' => 'facet_value'}}
    value = 'facet_value'
    label = 'facet_label'
    count = 1

    expected_url = {:facet => {'facet_solr_field' => 'facet_value'}}

    expects(:link_to).with('facet_label', expected_url, anything).returns('<link_to_result>')
    stubs(:content_tag).with(anything, '', anything).returns('<content_tag_extra>')
    stubs(:content_tag).with(anything, ' (1)', anything).returns('<content_tag_count>')
    stubs(:content_tag).with(anything, '<link_to_result><content_tag_extra><content_tag_count>', {:class => 'facet-menu-item facet-result-link-selected'}).returns('<content_tag_final_result>')

    assert_equal '<content_tag_final_result>', 
      facet_link_html(facet, params, value, label, count)
  end

  should 'show html for non-hash selected facets' do
    klass = mock
    klass.stubs(:facet_by_id).with(:facet_id).returns('klass_facet_by_id')
    klass.stubs(:facet_label).with('klass_facet_by_id').returns('klass_facet_label')
    klass.stubs(:facet_result_name).with('klass_facet_by_id', 'facet_value').returns('klass_facet_result_name')
    params = {:facet => {:facet_id => 'facet_value'}}
    
    expects(:content_tag).with(anything, 'klass_facet_label', anything).returns('<content_tag_label>')
    expects(:content_tag).with(anything, 'klass_facet_result_name', anything).returns('<content_tag_name>')
    expects(:link_to).with(anything, {:facet => {}}, anything).returns('<link_to_url>')
    expects(:content_tag).with(anything, '<content_tag_label><content_tag_name><link_to_url>', anything).returns('<final_content>')

    environment = mock
    assert_match '<final_content>', facet_selecteds_html_for(environment, klass, params)
  end 

  should 'show select tag for order_by' do
    [:products, :events, :articles, :enterprises, :people, :communities].each do |asset|
      params = {:order_by => 'Relevance'}

      stubs(:params).returns(params)
			stubs(:logged_in?).returns(false)
      stubs(:options_for_select).with(instance_of(Array), params[:order_by]).returns('<options_for_select>')
      stubs(:select_tag).with(regexp_matches(/#{asset}/), '<options_for_select>', anything).returns('<select_tag>')
      expects(:content_tag).with(anything, regexp_matches(/<select_tag>/), anything).returns('<final_content>')

      assert_equal '<final_content>', order_by(asset)
    end
  end

  should 'show total of assets found' do
    [:products, :events, :articles, :enterprises, :people, :communities].each do |asset|
      expects(:content_tag).with(anything, regexp_matches(/10.*#{asset}.*found/), anything).returns('<final_content>')
      assert_equal '<final_content>', label_total_found(asset, 10)
    end
  end
    
  should 'return asset class from string' do
    asset_names = ['products', 'events', 'articles', 'enterprises', 'people', 'communities']
    asset_classes = [Product, Event, Article, Enterprise, Person, Community]
    asset_names.each_index do |i|
      assert_equal asset_classes[i], asset_class(asset_names[i])
    end
  end

  should 'return asset table from string' do
    asset_classes = [Product, Event, Article, Enterprise, Person, Community]
    asset_tables = ['products', 'articles', 'articles', 'profiles', 'profiles', 'profiles']
    asset_classes.each_index do |i|
      assert_equal asset_tables[i], asset_table(asset_classes[i])
    end
  end

end
