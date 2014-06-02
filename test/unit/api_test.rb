require File.dirname(__FILE__) + '/../test_helper'

class APITest < ActiveSupport::TestCase

  include Rack::Test::Methods

  def app
    API::API
  end

  def setup
    @user = User.create!(:login => 'testapi', :password => 'testapi', :password_confirmation => 'testapi', :email => 'test@test.org', :environment => Environment.default)
    @user.activate

    post "/api/v1/login?login=testapi&password=testapi"
    json = JSON.parse(last_response.body)
    @private_token = json["private_token"]
    @params = {:private_token => @private_token}
  end
  attr_accessor :private_token, :user, :params

  should 'generate private token when login' do
    params = {:login => "testapi", :password => "testapi"}
    post "/api/v1/login?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert !json["private_token"].blank?
  end

  should 'return 401 when login fails' do
    user.destroy
    params = {:login => "testapi", :password => "testapi"}
    post "/api/v1/login?#{params.to_query}"
    assert_equal 401, last_response.status
  end

  should 'register a user' do
    params = {:login => "newuserapi", :password => "newuserapi", :email => "newuserapi@email.com" }
    post "/api/v1/register?#{params.to_query}"
    assert_equal 201, last_response.status
  end

  should 'do not register a user without email' do
    params = {:login => "newuserapi", :password => "newuserapi", :email => nil }
    post "/api/v1/register?#{params.to_query}"
    assert_equal 400, last_response.status
  end

  should 'do not register a duplicated user' do
    params = {:login => "newuserapi", :password => "newuserapi", :email => "newuserapi@email.com" }
    post "/api/v1/register?#{params.to_query}"
    post "/api/v1/register?#{params.to_query}"
    assert_equal 400, last_response.status
  end

  should 'list articles' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["articles"].map { |a| a["id"] }, article.id
  end

  should 'return article by id' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    get "/api/v1/articles/#{article.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json["article"]["id"]
  end

  should 'return comments of an article' do
    article = fast_create(Article, :profile_id => user.person.id, :name => "Some thing")
    article.comments.create!(:body => "some comment", :author => user.person)
    article.comments.create!(:body => "another comment", :author => user.person)

    get "/api/v1/articles/#{article.id}/comments?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 2, json["comments"].length
  end

  should 'list users' do
    get "/api/v1/users/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["users"].map { |a| a["login"] }, user.login
  end

  should 'list user permissions' do
    community = fast_create(Community)
    community.add_admin(user.person)
    get "/api/v1/users/#{user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["user"]["permissions"], community.identifier
  end

  should 'list categories' do
    category = fast_create(Category)
    get "/api/v1/categories/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["categories"].map { |c| c["name"] }, category.name
  end

  should 'get category by id' do
    category = fast_create(Category)
    get "/api/v1/categories/#{category.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal category.name, json["category"]["name"]
  end

end
