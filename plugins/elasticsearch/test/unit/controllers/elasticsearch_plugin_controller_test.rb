require "#{File.dirname(__FILE__)}/../../test_helper"

class ElasticsearchPluginControllerTest < ActionController::TestCase

  def setup
    @environment = Environment.default
    @environment.enable_plugin(ElasticsearchPlugin)
    create_user('John Silva').person
    create_user('John Silvio').person
    community = fast_create(Community)
    community.name = "I like organic"
    community.created_at = Time.now
    community.save
    Community.import
    sleep 1

    #TODO: fix this, when update or create a new person
    # the Elasticsearch::Model can update the
    # indexes models
    Person.import
    sleep 1

  end

  should 'work and uses control filter variables' do
    get :index
    assert_response :success
    assert_not_nil assigns(:searchable_types)
    assert_not_nil assigns(:selected_type)
    assert_not_nil assigns(:search_filter_types)
    assert_not_nil assigns(:selected_filter_field)
  end

  should 'return all results if selected_type is nil' do
    get :index, {'selected_type' => :person, :query => 'John'}
    assert_response :success
    assert_select ".search-item" , 2
  end

  should 'render index' do
    get :index, {'selected_type' => :person, :query => 'Silva'}
    assert_response :success
    assert_select ".search-item" , 1
  end

  should 'redirect to elasticsearch plugin when request are send to core' do
    oldcontroller = @controller
    @controller = SearchController.new
    get 'index'
    params = {}
    params[:action] = 'index'
    params[:controller] = 'search'
    assert_redirected_to controller: 'elasticsearch_plugin', action: 'search', params: params
    @controller = oldcontroller
  end

  should 'pass params to elastic search controller' do
    get 'index', { query: 'like' }
    assert_not_nil assigns(:results)
    assert_template partial: '_community_display'
  end
end
