require_relative 'test_helper'

class PeopleTest < ActiveSupport::TestCase

  def setup
    Person.delete_all
  end

  should 'logged user list all people' do
    login_api
    person1 = fast_create(Person, :public_profile => true)
    person2 = fast_create(Person)
    get "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [person1.id, person2.id, person.id], json['people'].map {|c| c['id']}
  end

  should 'anonymous list all people' do
    anonymous_setup
    person1 = fast_create(Person, :public_profile => true)
    person2 = fast_create(Person)
    get "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [person1.id, person2.id], json['people'].map {|c| c['id']}
  end

  should 'logged user list all members of a community' do
    login_api
    person1 = fast_create(Person)
    person2 = fast_create(Person)
    community = fast_create(Community)
    community.add_member(person1)
    community.add_member(person2)

    get "/api/v1/profiles/#{community.id}/members?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 2, json["people"].count
    assert_equivalent [person1.id,person2.id], json["people"].map{|p| p["id"]}
  end

  should 'anonymous list all members of a community' do
    anonymous_setup
    person1 = fast_create(Person)
    person2 = fast_create(Person)
    community = fast_create(Community)
    community.add_member(person1)
    community.add_member(person2)

    get "/api/v1/profiles/#{community.id}/members?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 2, json["people"].count
    assert_equivalent [person1.id,person2.id], json["people"].map{|p| p["id"]}
  end

  should 'logged user not list invisible people' do
    login_api
    invisible_person = fast_create(Person, :visible => false)

    get "/api/v1/people?#{params.to_query}"
    assert_not_includes json_response_ids(:people), invisible_person.id
  end

  should 'annoymous not list invisible people' do
    invisible_person = fast_create(Person, :visible => false)

    get "/api/v1/people?#{params.to_query}"
    assert_not_includes json_response_ids(:people), invisible_person.id
  end

  should 'logged user list private people' do
    login_api
    private_person = fast_create(Person, :public_profile => false)

    get "/api/v1/people?#{params.to_query}"
    assert_includes json_response_ids(:people), private_person.id
  end

  should 'anonymous list private people' do
    anonymous_setup
    private_person = fast_create(Person, :public_profile => false)

    get "/api/v1/people?#{params.to_query}"
    assert_includes json_response_ids(:people), private_person.id
  end

  should 'logged user list private person for friends' do
    login_api
    p1 = fast_create(Person)
    p2 = fast_create(Person, :public_profile => false)
    person.add_friend(p2)
    p2.add_friend(person)

    get "/api/v1/people?#{params.to_query}"
    assert_includes json_response_ids(:people), p2.id
  end

  should 'logged user get person' do
    login_api
    some_person = fast_create(Person)

    get "/api/v1/people/#{some_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal some_person.id, json['person']['id']
  end

  should 'anonymous get person' do
    some_person = fast_create(Person)

    get "/api/v1/people/#{some_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal some_person.id, json['person']['id']
  end

  should 'people endpoint filter by fields parameter for logged user' do
    login_api
    get "/api/v1/people?#{params.to_query}&fields=name"
    json = JSON.parse(last_response.body)
    expected = {'people' => [{'name' => person.name}]}
    assert_equal expected, json
  end

  should 'people endpoint filter by fields parameter with hierarchy for logged user' do
    login_api
    fields = URI.encode({only: [:name, {user: [:login]}]}.to_json.to_str)
    get "/api/v1/people?#{params.to_query}&fields=#{fields}"
    json = JSON.parse(last_response.body)
    expected = {'people' => [{'name' => person.name, 'user' => {'login' => 'testapi'}}]}
    assert_equal expected, json
  end

  should 'get logged person' do
    login_api
    get "/api/v1/people/me?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal person.id, json['person']['id']
  end

  should 'access me endpoint filter by fields parameter' do
    login_api
    get "/api/v1/people/me?#{params.to_query}&fields=name"
    json = JSON.parse(last_response.body)
    expected = {'person' => {'name' => person.name}}
    assert_equal expected, json
  end

  should 'logged user not get invisible person' do
    login_api
    person = fast_create(Person, :visible => false)

    get "/api/v1/people/#{person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['person'].blank?
  end

  should 'anonymous not get invisible person' do
    person = fast_create(Person, :visible => false)

    get "/api/v1/people/#{person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['person'].blank?
  end

  should 'get private people' do
    login_api
    private_person = fast_create(Person, :public_profile => false)

    get "/api/v1/people/#{private_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['person']['id'], private_person.id
  end

  should 'anonymous get private people' do
    anonymous_setup
    private_person = fast_create(Person, :public_profile => false)

    get "/api/v1/people/#{private_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['person']['id'], private_person.id
  end

  should 'get private person for friends' do
    login_api
    private_person = fast_create(Person, :public_profile => false)
    person.add_friend(private_person)
    private_person.add_friend(person)

    get "/api/v1/people/#{private_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal private_person.id, json['person']['id']
  end

  should 'list person friends' do
    login_api
    friend = fast_create(Person)
    person.add_friend(friend)
    friend.add_friend(person)
    get "/api/v1/people/#{friend.id}/friends?#{params.to_query}"
    assert_includes json_response_ids(:people), person.id
  end

  should 'anonymous list person friends' do
    anonymous_setup
    person = fast_create(Person)
    friend = fast_create(Person)
    person.add_friend(friend)
    friend.add_friend(person)
    get "/api/v1/people/#{friend.id}/friends?#{params.to_query}"
    assert_includes json_response_ids(:people), person.id
  end

  should 'not list person invisible friends' do
    login_api
    friend = fast_create(Person)
    invisible_friend = fast_create(Person, :visible => false)
    person.add_friend(friend)
    person.add_friend(invisible_friend)
    friend.add_friend(person)
    invisible_friend.add_friend(person)

    get "/api/v1/people/#{person.id}/friends?#{params.to_query}"
    friends = json_response_ids(:people)
    assert_includes friends, friend.id
    assert_not_includes friends, invisible_friend.id
  end

  should 'create a person' do
    login_api
    login = 'some'
    params[:person] = {:login => login, :password => '123456', :password_confirmation => '123456', :email => 'some@some.com'}
    post "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal login, json['person']['identifier']
  end

  should 'return 400 status for invalid person creation' do
    login_api
    params[:person] = {:login => 'some'}
    post "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 400, last_response.status
  end

  should 'display permissions' do
    login_api
    community = fast_create(Community)
    community.add_member(fast_create(Person))
    community.add_member(person)
    permissions = Profile::Roles.member(person.environment.id).permissions
    get "/api/v1/people/#{person.id}/permissions?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal json[community.identifier], permissions
  end

  should 'display permissions if self' do
    login_api
    get "/api/v1/people/#{person.id}/permissions?#{params.to_query}"
    assert_equal 200, last_response.status
  end

  should 'display permissions if admin' do
    login_api
    environment = person.environment
    environment.add_admin(person)
    some_person = fast_create(Person)

    get "/api/v1/people/#{some_person.id}/permissions?#{params.to_query}"
    assert_equal 200, last_response.status
  end

  should 'not display permissions if not admin or self' do
    login_api
    some_person = create_user('some-person').person

    get "/api/v1/people/#{some_person.id}/permissions?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'not update another person' do
    login_api
    person = fast_create(Person, :environment_id => environment.id)
    post "/api/v1/people/#{person.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'update yourself' do
    login_api
    another_name = 'Another Name'
    params[:person] = {}
    params[:person][:name] = another_name
    assert_not_equal another_name, person.name
    post "/api/v1/people/#{person.id}?#{params.to_query}"
    person.reload
    assert_equal another_name, person.name
  end

  should 'logged user display public custom fields' do
    login_api
    CustomField.create!(:name => "Custom Blog", :format => "string", :customized_type => "Person", :active => true, :environment => Environment.default)
    some_person = create_user('some-person').person
    some_person.custom_values = { "Custom Blog" => { "value" => "www.blog.org", "public" => "true"} }
    some_person.save!

    get "/api/v1/people/#{some_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['person']['additional_data'].has_key?('Custom Blog')
    assert_equal "www.blog.org", json['person']['additional_data']['Custom Blog']
  end

  should 'logged user not display non-public custom fields' do
    login_api
    CustomField.create!(:name => "Custom Blog", :format => "string", :customized_type => "Person", :active => true, :environment => Environment.default)
    some_person = create_user('some-person').person
    some_person.custom_values = { "Custom Blog" => { "value" => "www.blog.org", "public" => "0"} }
    some_person.save!

    get "/api/v1/people/#{some_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['person']['additional_data'], {}
  end

  should 'display public custom fields to anonymous' do
    anonymous_setup
    CustomField.create!(:name => "Custom Blog", :format => "string", :customized_type => "Person", :active => true, :environment => Environment.default)
    some_person = create_user('some-person').person
    some_person.custom_values = { "Custom Blog" => { "value" => "www.blog.org", "public" => "true"} }
    some_person.save!

    get "/api/v1/people/#{some_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['person']['additional_data'].has_key?('Custom Blog')
    assert_equal "www.blog.org", json['person']['additional_data']['Custom Blog']
  end

  should 'not display non-public custom fields to anonymous' do
    anonymous_setup
    CustomField.create!(:name => "Custom Blog", :format => "string", :customized_type => "Person", :active => true, :environment => Environment.default)
    some_person = create_user('some-person').person
    some_person.custom_values = { "Custom Blog" => { "value" => "www.blog.org", "public" => "0"} }
    some_person.save!

    get "/api/v1/people/#{some_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['person']['additional_data'], {}
  end

  should 'hide private fields to anonymous' do
    anonymous_setup
    target_person = create_user('some-user').person
    target_person.save!

    get "/api/v1/users/#{target_person.user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    refute json["user"].has_key?("permissions")
    refute json["user"].has_key?("activated")
  end

  should 'display non-public custom fields to friend' do
    login_api
    CustomField.create!(:name => "Custom Blog", :format => "string", :customized_type => "Person", :active => true, :environment => Environment.default)
    some_person = create_user('some-person').person
    some_person.custom_values = { "Custom Blog" => { "value" => "www.blog.org", "public" => "0"} }
    some_person.save!

    f = Friendship.new
    f.friend = some_person
    f.person = person
    f.save!

    get "/api/v1/people/#{some_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['person']['additional_data'].has_key?("Custom Blog")
    assert_equal "www.blog.org", json['person']['additional_data']['Custom Blog']
  end

  PERSON_ATTRIBUTES = %w(vote_count comments_count articles_count following_articles_count)

  PERSON_ATTRIBUTES.map do |attribute|
    define_method "test_should_not_expose_#{attribute}_attribute_in_person_enpoint_if_field_parameter_does_not_contain_the_attribute" do
      login_api
      get "/api/v1/people/me?#{params.to_query}&fields=name"
      json = JSON.parse(last_response.body)
      assert_nil json['person'][attribute]
    end

    define_method "test_should_expose_#{attribute}_attribute_in_person_enpoints_if_field_parameter_is_passed" do
      login_api
      get "/api/v1/people/me?#{params.to_query}&fields=#{attribute}"
      json = JSON.parse(last_response.body)
      assert_not_nil json['person'][attribute]
    end
  end
end
