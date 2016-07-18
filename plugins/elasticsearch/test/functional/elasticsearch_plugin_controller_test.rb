require "#{File.dirname(__FILE__)}/../test_helper"

class ElasticsearchPluginControllerTest < ActionController::TestCase

  include ElasticsearchTestHelper

  def indexed_models
    [Person,TextArticle,UploadedFile,Community,Event]
  end

  def create_instances
    create_instances_environment
    create_instances_environment2
  end

  def create_instances_environment2
    create_user "Sample User Environment 2", environment:Environment.second
    fast_create Community, name:"Sample Community Environment 2", created_at: Date.new, environment_id: Environment.second.id
  end

  def create_instances_environment
    create_visible_models
    create_private_models
  end

  def create_visible_models
    categories = []
    5.times do | index |
      categories[index] = fast_create Category, name: "Category#{index}", id: index+1
      create_user "person #{index}"
    end

    6.times do | index |
      community = fast_create Community, name: "community #{index}", created_at: Date.new
      if categories[index]
        community.categories.push categories[index]
        community.save
      end
    end
  end

  def create_private_models
    secret_user = create_user("Secret Person")
    fast_update(secret_user.person, secret: true, visible: true)

    invisible_user= create_user("Invisible Person")
    fast_update(invisible_user.person, secret: false, visible: false, public_profile: false)

    fast_create(Community, name: "secret community", secret: true, visible: true)
    fast_create(Community, name: "invisible community", secret: false, visible: false)

    create_private_article(TextArticle,public_person: User.first.person, private_person: invisible_user.person)
    create_private_article(UploadedFile,public_person: User.first.person, private_person: invisible_user.person)
    create_private_article(Event,public_person: User.first.person, private_person: invisible_user.person)
  end

  def create_private_article model,options = {}
    public_person = options[:public_person]
    private_person = options[:private_person]

    fast_create(model, name: "#{model.to_s.underscore} not advertise", advertise: false, published: true, profile_id: public_person, created_at: Time.now)
    fast_create(model, name: "#{model.to_s.underscore} not published", advertise: true, published: false, profile_id: public_person, created_at: Time.now)
    fast_create(model, name: "#{model.to_s.underscore} with not visible profile", advertise: true, published: true, profile_id: private_person, created_at: Time.now)
    fast_create(model, name: "#{model.to_s.underscore} with not public_profile", advertise: true, published: true, profile_id: private_person, created_at: Time.now)
  end


  should 'work and uses control filter variables' do
    get :index
    assert_response :success
    assert_not_nil assigns(:searchable_types)
    assert_not_nil assigns(:selected_type)
    assert_not_nil assigns(:sort_types)
    assert_not_nil assigns(:selected_sort)
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
    get :index, { 'selected_type' => :community}
    assert_response :success
    assert_select ".search-item", 6
    assert_template partial: '_community_display'
  end

  should 'return results filtered by query' do
    get :index, { 'query' => "person"}
    assert_response :success
    assert_select ".search-item", 5
    assert_template partial: '_person_display'
  end

  should 'return results filtered by query with uppercase' do
    get :index, {'query' => "PERSON 1"}
    assert_response :success
    assert_template partial: '_person_display'
    assert_tag(tag: "div", attributes: { class: "person-item" } , descendant: { tag: "a", child: "person 1"} )
  end

  should 'return results filtered by query with downcase' do
    get :index, {'query' => "person 1"}
    assert_response :success
    assert_tag(tag: "div", attributes: { class: "person-item" } , descendant: { tag: "a", child: "person 1"} )
  end

  should 'return new community indexed' do
    get :index, { "selected_type" => :community}
    assert_response :success
    assert_select ".search-item", 6

    fast_create Community, name: "community #{7}", created_at: Date.new
    Community.import
    sleep 2

    get :index, { "selected_type" => :community}
    assert_response :success
    assert_select ".search-item", 7
  end

  should 'not return community deleted' do
    get :index, { "selected_type" => :community}
    assert_response :success
    assert_select ".search-item", 6

    Community.first.delete
    Community.import
    sleep 2

    get :index, { "selected_type" => :community}
    assert_response :success
    assert_select ".search-item", 5
  end

  should 'redirect to elasticsearch plugin when request are send to core' do
    @controller = SearchController.new
    get 'index'
    params = {:action => 'index', :controller => 'search'}
    assert_redirected_to controller: 'elasticsearch_plugin', action: 'search', params: params
  end

  should 'filter community by default environment' do
    get :index, { "selected_type" => :community}
    assert_response :success
    assert_select ".search-item", 6
  end

  should 'filter person by default environment' do
    get :index, { "selected_type" => :person}
    assert_response :success
    assert_select ".search-item", 5
  end

  should 'not show private text_article' do
    get :index, { :selected_type => "text_article" }
    assert_response :success
    assert_select ".search-item", 6
  end

  should 'not show private uploaded_file' do
    get :index, { :selected_type => "uploaded_file" }
    assert_response :success
    assert_select ".search-item", 0
  end

  should 'not show private event' do
    get :index, { :selected_type => "event" }
    assert_response :success
    assert_select ".search-item", 0
  end

  should 'filter by selected categories' do
    get :index, { "categories" => "1,2,3" }
    assert_response :success
    assert_select ".search-item", 3
    get :index, { "categories" => "5" }
    assert_response :success
    assert_select ".search-item", 1
  end

end
