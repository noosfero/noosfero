require_relative 'test_helper'

class PeopleTest < ActiveSupport::TestCase

  def setup
    Person.destroy_all
    create_and_activate_user
  end

  should 'logged user list all people' do
    login_api
    person1 = fast_create(Person, :public_profile => true)
    person2 = fast_create(Person)
    get "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [person1.id, person2.id, person.id], json.map {|c| c['id']}
  end

  should 'anonymous list all people' do
    person1 = fast_create(Person, :public_profile => true)
    person2 = fast_create(Person)
    get "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [person.id, person1.id, person2.id], json.map {|c| c['id']}
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
    assert_equal 2, json.count
    assert_equivalent [person1.id,person2.id], json.map{|p| p["id"]}
  end

  should 'anonymous list all members of a community' do
    person1 = fast_create(Person)
    person2 = fast_create(Person)
    community = fast_create(Community)
    community.add_member(person1)
    community.add_member(person2)

    get "/api/v1/profiles/#{community.id}/members?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 2, json.count
    assert_equivalent [person1.id,person2.id], json.map{|p| p["id"]}
  end

  should 'logged user not list invisible people' do
    login_api
    invisible_person = fast_create(Person, :visible => false)

    get "/api/v1/people?#{params.to_query}"
    assert_not_includes json_response_ids, invisible_person.id
  end

  should 'annoymous not list invisible people' do
    invisible_person = fast_create(Person, :visible => false)

    get "/api/v1/people?#{params.to_query}"
    assert_not_includes json_response_ids, invisible_person.id
  end

  should 'logged user list private people' do
    login_api
    private_person = fast_create(Person, :public_profile => false)

    get "/api/v1/people?#{params.to_query}"
    assert_includes json_response_ids, private_person.id
  end

  should 'anonymous list private people' do
    private_person = fast_create(Person, :public_profile => false)

    get "/api/v1/people?#{params.to_query}"
    assert_includes json_response_ids, private_person.id
  end

  should 'logged user list private person for friends' do
    login_api
    p1 = fast_create(Person)
    p2 = fast_create(Person, :public_profile => false)
    person.add_friend(p2)
    p2.add_friend(person)

    get "/api/v1/people?#{params.to_query}"
    assert_includes json_response_ids, p2.id
  end

  should 'logged user get person' do
    login_api
    some_person = fast_create(Person)

    get "/api/v1/people/#{some_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal some_person.id, json['id']
  end

  should 'anonymous get person' do
    some_person = fast_create(Person)

    get "/api/v1/people/#{some_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal some_person.id, json['id']
  end

  should 'people endpoint filter by fields parameter for logged user' do
    login_api
    get "/api/v1/people?#{params.to_query}&fields=name"
    json = JSON.parse(last_response.body)
    expected = [{'name' => person.name}]
    assert_equal expected, json
  end

  should 'people endpoint filter by fields parameter with hierarchy for logged user' do
    login_api
    params[:fields] = {only: [:name, {user: [:login]}]}
    get "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    expected = [{'name' => person.name, 'user' => {'login' => 'testapi'}}]
    assert_equal expected, json
  end

  should 'get logged person' do
    login_api
    get "/api/v1/people/me?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal person.id, json['id']
  end

  should 'access me endpoint filter by fields parameter' do
    login_api
    get "/api/v1/people/me?#{params.to_query}&fields=name"
    json = JSON.parse(last_response.body)
    expected = {'name' => person.name}
    assert_equal expected, json
  end

  should 'logged user not get invisible person' do
    login_api
    person = fast_create(Person, :visible => false)

    get "/api/v1/people/#{person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal Api::Status::Http::NOT_FOUND, last_response.status
  end

  should 'anonymous not get invisible person' do
    person = fast_create(Person, :visible => false)

    get "/api/v1/people/#{person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal Api::Status::Http::NOT_FOUND, last_response.status
  end

  should 'get private people' do
    login_api
    private_person = fast_create(Person, :public_profile => false)

    get "/api/v1/people/#{private_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['id'], private_person.id
  end

  should 'anonymous get private people' do
    private_person = fast_create(Person, :public_profile => false)

    get "/api/v1/people/#{private_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['id'], private_person.id
  end

  should 'get private person for friends' do
    login_api
    private_person = fast_create(Person, :public_profile => false)
    person.add_friend(private_person)
    private_person.add_friend(person)

    get "/api/v1/people/#{private_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal private_person.id, json['id']
  end

  should 'list person friends' do
    login_api
    friend = fast_create(Person)
    person.add_friend(friend)
    friend.add_friend(person)
    get "/api/v1/people/#{friend.id}/friends?#{params.to_query}"
    assert_includes json_response_ids, person.id
  end

  should 'anonymous list person friends' do
    person = fast_create(Person)
    friend = fast_create(Person)
    person.add_friend(friend)
    friend.add_friend(person)
    get "/api/v1/people/#{friend.id}/friends?#{params.to_query}"
    assert_includes json_response_ids, person.id
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
    friends = json_response_ids
    assert_includes friends, friend.id
    assert_not_includes friends, invisible_friend.id
  end

  should 'create a person' do
    login_api
    login = 'some'
    params[:person] = {:login => login, :password => '123456', :password_confirmation => '123456', :email => 'some@some.com'}
    post "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal login, json['identifier']
  end

  should "return #{Api::Status::Http::UNPROCESSABLE_ENTITY} status for invalid person creation" do
    login_api
    params[:person] = {:login => 'some'}
    post "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal Api::Status::Http::UNPROCESSABLE_ENTITY, last_response.status
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
    some_person = fast_create(Person)

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
    CustomField.create!(:name => "Custom Blog", :format => "string", :customized_type => "Person", :active => true, :environment => environment)
    some_person = User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment).person
    some_person.user.activate
    some_person.reload

    some_person.custom_values = { "Custom Blog" => { "value" => "www.blog.org", "public" => "true"} }
    some_person.save!

    get "/api/v1/people/#{some_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['additional_data'].has_key?('Custom Blog')
    assert_equal "www.blog.org", json['additional_data']['Custom Blog']
  end

  should 'logged user not display non-public custom fields' do
    login_api
    CustomField.create!(:name => "Custom Blog", :format => "string", :customized_type => "Person", :active => true, :environment => environment)
    some_person = User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment).person
    some_person.custom_values = { "Custom Blog" => { "value" => "www.blog.org", "public" => "0"} }
    some_person.save!
    some_person.user.activate

    get "/api/v1/people/#{some_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['additional_data'], {}
  end

  should 'display public custom fields to anonymous' do
    CustomField.create!(:name => "Custom Blog", :format => "string", :customized_type => "Person", :active => true, :environment => environment)
    person.reload
    person.custom_values = { "Custom Blog" => { "value" => "www.blog.org", "public" => "true"} }
    person.save!

    get "/api/v1/people/#{person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['additional_data'].has_key?('Custom Blog')
    assert_equal "www.blog.org", json['additional_data']['Custom Blog']
  end

  should 'not display non-public custom fields to anonymous' do
    CustomField.create!(:name => "Custom Blog", :format => "string", :customized_type => "Person", :active => true, :environment => environment)
    person.custom_values = { "Custom Blog" => { "value" => "www.blog.org", "public" => "0"} }
    person.save!

    get "/api/v1/people/#{person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['additional_data'], {}
  end

  should 'hide private fields to anonymous' do
    target_user = User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment)

    get "/api/v1/users/#{target_user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    refute json.has_key?("permissions")
    refute json.has_key?("activated")
  end

  should 'display non-public custom fields to friend' do
    login_api
    CustomField.create!(:name => "Custom Blog", :format => "string", :customized_type => "Person", :active => true, :environment => environment)
    some_person = User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment).person
    some_person.user.activate
    some_person.reload

    some_person.custom_values = { "Custom Blog" => { "value" => "www.blog.org", "public" => "0"} }
    some_person.save!

    some_person.add_friend(person)
    person.add_friend(some_person)

    get "/api/v1/people/#{some_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['additional_data'].has_key?("Custom Blog")
    assert_equal "www.blog.org", json['additional_data']['Custom Blog']
  end

  PERSON_ATTRIBUTES = %w(vote_count comments_count articles_count following_articles_count friends_count)

  PERSON_ATTRIBUTES.map do |attribute|
    define_method "test_should_not_expose_#{attribute}_attribute_in_person_enpoint_if_field_parameter_does_not_contain_the_attribute" do
      login_api
      get "/api/v1/people/me?#{params.to_query}&fields=name"
      json = JSON.parse(last_response.body)
      assert_nil json[attribute]
    end

    define_method "test_should_expose_#{attribute}_attribute_in_person_enpoints_if_field_parameter_is_passed" do
      login_api
      get "/api/v1/people/me?#{params.to_query}&fields=#{attribute}"
      json = JSON.parse(last_response.body)
      assert_not_nil json[attribute]
    end
  end

  should 'update person image' do
    login_api
    base64_image = create_base64_image
    params.merge!({person: {image_builder: base64_image}})
    assert_nil person.image
    post "/api/v1/people/#{person.id}?#{params.to_query}"
    person.reload
    assert_not_nil person.image
    assert_equal person.image.filename, base64_image[:filename]
  end

  should 'add logged person as member of a profile' do
    login_api
    profile = fast_create(Community)
    post "/api/v1/profiles/#{profile.id}/members?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['pending'], false
    assert person.is_member_of?(profile)
  end

  should 'create task when add logged person as member of a moderated profile' do
    login_api
    profile = fast_create(Community, public_profile: false)
    profile.add_member(create_user.person)
    profile.closed = true
    profile.save!
    post "/api/v1/profiles/#{profile.id}/members?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['pending'], true
    assert !person.is_member_of?(profile)
  end

  should 'remove logged person as member of a profile' do
    login_api
    profile = fast_create(Community)
    profile.add_member(person)
    delete "/api/v1/profiles/#{profile.id}/members?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal person.identifier, json['identifier']
    assert !person.is_member_of?(profile)
  end

  should 'forbid access to add members for non logged user' do
    profile = fast_create(Community)
    post "/api/v1/profiles/#{profile.id}/members?#{params.to_query}"
    assert_equal 401, last_response.status
  end

  should 'forbid access to remove members for non logged user' do
    profile = fast_create(Community)
    delete "/api/v1/profiles/#{profile.id}/members?#{params.to_query}"
    assert_equal 401, last_response.status
  end

  should 'forbid to add person as member when the profile does not allow' do
    login_api
    profile = fast_create(Person)
    post "/api/v1/profiles/#{profile.id}/members?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'forbid to add person as member when the profile is secret' do
    login_api
    profile = fast_create(Community, secret: true)
    post "/api/v1/profiles/#{profile.id}/members?#{params.to_query}"
    assert !person.is_member_of?(profile)
    assert_equal 403, last_response.status
  end

  should 'list all people of enviroment' do
    environment = fast_create(Environment)
    person1 = fast_create(Person, :public_profile => true, :environment_id => environment.id)
    person2 = fast_create(Person, :environment_id => environment.id)
    get "/api/v1/environments/#{environment.id}/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [person1.id, person2.id], json.map {|c| c['id']}
  end

  should 'logged user not list invisible people of environment' do
    environment = fast_create(Environment)
    login_api
    invisible_person = fast_create(Person, :visible => false, :environment_id => environment.id)

    get "/api/v1/environments/#{environment.id}/people?#{params.to_query}"
    assert_not_includes json_response_ids, invisible_person.id
  end

  should 'annoymous not list invisible people of environment' do
    environment = fast_create(Environment)
    invisible_person = fast_create(Person, :visible => false, :environment_id => environment.id)

    get "/api/v1/environments/#{environment.id}/people?#{params.to_query}"
    assert_not_includes json_response_ids, invisible_person.id
  end

  should 'logged user list private people of environment' do
    environment = fast_create(Environment)
    login_api
    private_person = fast_create(Person, :public_profile => false, :environment_id => environment.id)

    get "/api/v1/environments/#{environment.id}/people?#{params.to_query}"
    assert_includes json_response_ids, private_person.id
  end

  should 'anonymous list private people of environment' do
    environment = fast_create(Environment)
    private_person = fast_create(Person, :public_profile => false, :environment_id => environment.id)

    get "/api/v1/environments/#{environment.id}/people?#{params.to_query}"
    assert_includes json_response_ids, private_person.id
  end

  should 'logged user list private person for friends of environment' do
    environment = fast_create(Environment)
    login_api
    p1 = fast_create(Person, :environment_id => environment.id)
    p2 = fast_create(Person, :public_profile => false, :environment_id => environment.id)
    person.add_friend(p2)
    p2.add_friend(person)

    get "/api/v1/environments/#{environment.id}/people?#{params.to_query}"
    assert_includes json_response_ids, p2.id
  end

  should 'people endpoint filter by fields parameter for logged user of environment' do
    environment = fast_create(Environment)
    person  = fast_create(Person, :environment_id => environment.id)
    get "/api/v1/environments/#{environment.id}/people?#{params.to_query}&fields=name"
    json = JSON.parse(last_response.body)
    expected = [{'name' => person.name}]
    assert_equal expected, json
  end

  should 'people endpoint filter by fields parameter with hierarchy for logged user of environment' do
    environment = fast_create(Environment)
    person  = create_user('someuser', :environment_id => environment.id).person
    params[:fields] = {only: [:name, {user: [:login]}]}
    get "/api/v1/environments/#{environment.id}/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    expected = [{'name' => 'someuser', 'user' => {'login' => 'someuser'}}]
    assert_equal expected, json
  end

  should 'list all people of default enviroment' do
    environment = Environment.default
    person1 = fast_create(Person, :public_profile => true, :environment_id => environment.id)
    person2 = fast_create(Person, :environment_id => environment.id)
    get "/api/v1/environments/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [person1.id, person2.id, person.id], json.map {|c| c['id']}
  end

  should 'logged user not list invisible people of default environment' do
    environment = Environment.default
    login_api
    invisible_person = fast_create(Person, :visible => false, :environment_id => environment.id)

    get "/api/v1/environments/people?#{params.to_query}"
    assert_not_includes json_response_ids, invisible_person.id
  end

  should 'annoymous not list invisible people of default environment' do
    environment = Environment.default
    invisible_person = fast_create(Person, :visible => false, :environment_id => environment.id)

    get "/api/v1/environments/people?#{params.to_query}"
    assert_not_includes json_response_ids, invisible_person.id
  end

  should 'logged user list private people of default environment' do
    environment = Environment.default
    login_api
    private_person = fast_create(Person, :public_profile => false, :environment_id => environment.id)

    get "/api/v1/environments/people?#{params.to_query}"
    assert_includes json_response_ids, private_person.id
  end

  should 'anonymous list private people of default environment' do
    environment = Environment.default
    private_person = fast_create(Person, :public_profile => false, :environment_id => environment.id)

    get "/api/v1/environments/people?#{params.to_query}"
    assert_includes json_response_ids, private_person.id
  end

  should 'logged user list private person for friends of default environment' do
    environment = Environment.default
    login_api
    p1 = fast_create(Person, :environment_id => environment.id)
    p2 = fast_create(Person, :public_profile => false, :environment_id => environment.id)
    person.add_friend(p2)
    p2.add_friend(person)

    get "/api/v1/environments/people?#{params.to_query}"
    assert_includes json_response_ids, p2.id
  end

  should 'people endpoint filter by fields parameter for logged user of default environment' do
    environment = Environment.default
    login_api
    get "/api/v1/environments/people?#{params.to_query}&fields=name"
    json = JSON.parse(last_response.body)
    expected = [{'name' => person.name}]
    assert_equal expected, json
  end

  should 'people endpoint filter by fields parameter with hierarchy for logged user of default environment' do
    environment = Environment.default
    login_api
    params[:fields] = {only: [:name, {user: [:login]}]}
    get "/api/v1/environments/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    expected = [{'name' => person.name, 'user' => {'login' => 'testapi'}}]
    assert_equal expected, json
  end

  should 'return the followers of a article identified by id' do
    person1 = fast_create(Person)
    article = fast_create(Article, :profile_id => person1.id, :name => "Some thing")

    ArticleFollower.create!(:article_id => article.id, :person_id => person1.id)

    get "/api/v1/articles/#{article.id}/followers?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal 1, json.length
    assert_equal person1.id, json.first['id']
  end

  should 'return the amount of followers of a article identified by id' do
    person1 = fast_create(Person)
    article = fast_create(Article, :profile_id => person1.id, :name => "Some thing")

    person2 = fast_create(Person)
    person3 = fast_create(Person)
    ArticleFollower.create!(:article_id => article.id, :person_id => person1.id)
    ArticleFollower.create!(:article_id => article.id, :person_id => person2.id)
    ArticleFollower.create!(:article_id => article.id, :person_id => person3.id)

    params[:count] = true
    get "/api/v1/articles/#{article.id}/followers?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 3, json['count']
  end

  should 'add a new person friend' do
    login_api
    friend = create_user('friend').person
    person.add_friend(friend)
    friend.add_friend(person)
    post "/api/v1/people/#{friend.id}/friends?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['message'], 'WAITING_APPROVAL'
  end
  
  should 'remove person friend' do
    login_api
    friend = fast_create(Person)
    person.add_friend(friend)
    friend.add_friend(person)
    delete "/api/v1/people/#{friend.id}/friends?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['message'], "Friend successfuly removed"
  end  

  should 'list a person friend' do
    login_api
    friend = fast_create(Person)
    person.add_friend(friend)
    friend.add_friend(person)
    get "/api/v1/people/#{friend.id}/friends/#{person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal json['id'], person.id
  end  

  should 'search for people' do
    person1 = fast_create(Person, :public_profile => true)
    person2 = fast_create(Person, name: 'John Snow')
    params[:search] = 'john'
    get "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [person2.id], json.map {|c| c['id']}
  end

  should 'search for people with pagination' do
    5.times { fast_create(Person, name: 'John Snow') }
    params[:search] = 'john'
    params[:per_page] = 2
    get "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 2, json.length
    assert_equal 5, last_response.headers['Total'].to_i
  end

  should 'search for friends' do
    login_api
    friend1 = fast_create(Person, name: 'John Snow')
    person.add_friend(friend1)
    friend2 = fast_create(Person, name: 'Other')
    person.add_friend(friend2)
    params[:search] = 'john'
    get "/api/v1/people/#{person.id}/friends?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [friend1.id], json_response_ids
  end

  should 'get membership state equal to 0 when user is not member' do
    login_api
    person = fast_create(Person)
    community = fast_create(Community)
    params[:identifier] = person.identifier
    get "/api/v1/profiles/#{community.id}/membership?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 0, json['membership_state']
  end

  should 'get membership state equal to 1 when user is waiting approval' do
    login_api
    person = fast_create(Person)
    community = fast_create(Community)
    community.update_attribute(:closed, true)
    TaskMailer.stubs(:deliver_target_notification)
    task = create(AddMember, :requestor_id => person.id, :target_id => community.id, :target_type => 'Profile')
    params[:identifier] = person.identifier
    get "/api/v1/profiles/#{community.id}/membership?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json['membership_state']
  end

  should 'get membership state equal to 2 when user is member' do
    login_api
    person = fast_create(Person)
    community = fast_create(Community)
    community.add_member(person)
    params[:identifier] = person.identifier
    get "/api/v1/profiles/#{community.id}/membership?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 2, json['membership_state']
  end

  #####
  
  ATTRIBUTES = [:email, :country, :state, :city, :nationality, :formation, :schooling]

  ATTRIBUTES.map do |attr|

    define_method "test_should_show_#{attr}_if_it_is_a_public_attribute_to_logged_user" do
      login_api
      target_person =  User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment).person
      target_person.public_profile = true
      target_person.visible = true
      target_person.fields_privacy={attr=> 'public'}
      target_person.save!
  
      get "/api/v1/people/#{target_person.id}/?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert json.has_key?(attr.to_s)
      assert_equal json[attr.to_s],target_person.send(attr)
    end
  
    define_method "test_should_not_show_#{attr}_if_it_is_an_private_attribute_to_logged_user_without_permission" do
      login_api
      target_person =  User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment).person
      target_person.public_profile = true
      target_person.visible = true
      target_person.fields_privacy={attr=> 'private'}
      target_person.save!
  
      get "/api/v1/people/#{target_person.id}/?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert !json.has_key?(attr.to_s)
    end
  
    define_method "test_should_not_show_#{attr}_if_it_is_an_private_attribute_to_logged_user_with_permission" do
      login_api
      target_person =  User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment).person
      target_person.public_profile = true
      target_person.visible = true
      target_person.fields_privacy={attr=> 'private'}
      target_person.save!
      target_person.add_friend(person)
  
      get "/api/v1/people/#{target_person.id}/?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert json.has_key?(attr.to_s)
    end
  
    define_method "test_should_not_show_email_if_it_is_a_private_attribute_to_logged_off_user" do
      logout_api
      target_person =  User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment).person
      target_person.public_profile = true
      target_person.visible = true
      target_person.fields_privacy={attr=> 'private'}
      target_person.save!
  
      get "/api/v1/people/#{target_person.id}/?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert !json.has_key?(attr.to_s)
    end
  end
end
