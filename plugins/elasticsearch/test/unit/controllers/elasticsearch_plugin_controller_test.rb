require "#{File.dirname(__FILE__)}/../../test_helper"

class ElasticsearchPluginControllerTest < ActionController::TestCase

  include ElasticsearchTestHelper

  def indexed_models
    [Community, Person]
  end

  def create_instances
    create_people
    create_communities
  end

  def create_people
    5.times do | index |
      create_user "person_#{index}"
    end
  end

  def create_communities
    10.times do | index |
      fast_create Community, name: "community_#{index}", created_at: Date.new
    end
  end

  should 'work and uses control filter variables' do
    get :index
    assert_response :success
    assert_not_nil assigns(:searchable_types)
    assert_not_nil assigns(:selected_type)
    assert_not_nil assigns(:search_filter_types)
    assert_not_nil assigns(:selected_filter_field)
  end

  should 'return 10 results if selected_type is nil and query is nil' do
    get :index
    assert_response :success
    assert_select ".search-item" , 10
  end

  should 'render pagination if results has more than 10' do
    get :index
    assert_response :success
    assert_select ".pagination", 1
  end

  should 'return results filtered by selected_type' do
    get :index, { 'selected_type' => :person}
    assert_response :success
    assert_select ".search-item", 5
    assert_template partial: '_person_display'
  end

  should 'return results filtered by query' do
    get :index, { 'query' => "person_"}
    assert_response :success
    assert_select ".search-item", 5
    assert_template partial: '_person_display'
  end

  should 'return results filtered by query with uppercase' do
    get :index, {'query' => "PERSON_1"}
    assert_response :success
    assert_select ".search-item", 1
    assert_template partial: '_person_display'
  end

  should 'return results filtered by query with downcase' do
    get :index, {'query' => "person_1"}
    assert_response :success
    assert_select ".search-item", 1
  end

  should 'return new person indexed' do
    get :index, { "selected_type" => :person}
    assert_response :success
    assert_select ".search-item", 5

    object = create_user "New Person"
    Person.import
    sleep 1

    get :index, { "selected_type" => :person}
    assert_response :success
    assert_select ".search-item", 6
  end

  should 'not return person deleted' do
    get :index, { "selected_type" => :person}
    assert_response :success
    assert_select ".search-item", 5

    Person.first.delete
    Person.import
    sleep 1

    get :index, { "selected_type" => :person}
    assert_response :success
    assert_select ".search-item", 4
  end

  should 'redirect to elasticsearch plugin when request are send to core' do
    @controller = SearchController.new
    get 'index'
    params = {:action => 'index', :controller => 'search'}
    assert_redirected_to controller: 'elasticsearch_plugin', action: 'search', params: params
  end

  should 'pass params to elastic search controller' do
    get 'index', { query: 'community_' }
    assert_not_nil assigns(:results)
    assert_template partial: '_community_display'
  end
end
