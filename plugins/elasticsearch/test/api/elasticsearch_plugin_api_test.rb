require_relative '../test_helper'
require_relative '../../helpers/elasticsearch_helper'

class ElasticsearchPluginApiTest < ActiveSupport::TestCase

  include ElasticsearchTestHelper
  include ElasticsearchHelper

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
    7.times{ | index |  create_user "person #{index}" }
    4.times{ | index |  fast_create Community, name: "community #{index}", created_at: Date.new }
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

  def create_instances
    5.times.each {|index| fast_create Category, name: "category#{index}", id: index+1 }
    7.times.each {|index| create_user "person #{index}"}
    4.times.each do |index|
      community = fast_create Community, name: "community #{index}"
      community.categories.push Category.find(index+1)
      community.save
    end
  end

  should 'show all types avaliable in /search/types endpoint' do
    get "/api/v1/search/types"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal searchable_types.stringify_keys.keys, json["types"]
  end

  should 'respond with endpoint /search with more than 10 results' do
    get "/api/v1/search"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 10, json["results"].count
  end

  should 'respond with query in downcase' do
    get "/api/v1/search?query=person"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 7, json["results"].count
  end

  should 'respond with query in uppercase' do
    get "/api/v1/search?query=PERSON"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 7, json["results"].count
  end

  should 'respond with selected_type' do
    get "/api/v1/search?selected_type=community"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 4, json["results"].count
  end

  should 'filter person by default environment' do
    get "/api/v1/search?selected_type=person"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 7, json["results"].count
  end

  should 'not show private text_article' do
    get "/api/v1/search?selected_type=text_article"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 7, json["results"].count
  end

  should 'respond with only the correct categories' do
    get "/api/v1/search?categories=1,2,3"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 3, json["results"].count
  end

  should 'respond with only categories from given model' do
    get "/api/v1/search?selected_type=community&categories=1,2,3"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 3, json["results"].count

    get "/api/v1/search?selected_type=person&categories=1,2"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 0, json["results"].count
  end

end
