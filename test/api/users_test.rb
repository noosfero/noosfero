# encoding: UTF-8
require_relative 'test_helper'

class UsersTest < ActiveSupport::TestCase

  should 'logger user list users' do
    login_api
    get "/api/v1/users/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["users"].map { |a| a["login"] }, user.login
  end

  should 'logger user get user info' do
    login_api
    get "/api/v1/users/#{user.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal user.id, json['user']['id']
  end

  should 'logger user list user permissions' do
    login_api
    community = fast_create(Community)
    community.add_admin(person)
    get "/api/v1/users/#{user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["user"]["permissions"], community.identifier
  end

  should 'get logged user' do
    login_api
    get "/api/v1/users/me?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal user.id, json['user']['id']
  end

  should 'not show permissions to logged user' do
    login_api
    target_person = create_user('some-user').person
    get "/api/v1/users/#{target_person.user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    refute json["user"].has_key?("permissions")
  end

  should 'logger user show permissions to self' do
    login_api
    get "/api/v1/users/#{user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json["user"].has_key?("permissions")
  end

  should 'not show permissions to friend' do
    login_api
    target_person = create_user('some-user').person

    f = Friendship.new
    f.friend = target_person
    f.person = person
    f.save!

    get "/api/v1/users/#{target_person.user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    refute json["user"].has_key?("permissions")
  end

  should 'not show private attribute to logged user' do
    login_api
    target_person = create_user('some-user').person
    get "/api/v1/users/#{target_person.user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    refute json["user"].has_key?("email")
  end

  should 'show private attr to friend' do
    login_api
    target_person = create_user('some-user').person
    f = Friendship.new
    f.friend = target_person
    f.person = person
    f.save!
    get "/api/v1/users/#{target_person.user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json["user"].has_key?("email")
    assert_equal target_person.email, json["user"]["email"]
  end

  should 'show public attribute to logged user' do
    login_api
    target_person = create_user('some-user').person
    target_person.fields_privacy={:email=> 'public'}
    target_person.save!
    get "/api/v1/users/#{target_person.user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json["user"].has_key?("email")
    assert_equal json["user"]["email"],target_person.email
  end

  should 'show public and private field to admin' do
    login_api
    Environment.default.add_admin(person)

    target_person = create_user('some-user').person
    target_person.fields_privacy={:email=> 'public'}
    target_person.save!

    get "/api/v1/users/#{target_person.user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json["user"].has_key?("email")
    assert json["user"].has_key?("permissions")
    assert json["user"].has_key?("activated")
  end

  should 'show public fields to anonymous' do
    anonymous_setup
    target_person = create_user('some-user').person
    target_person.fields_privacy={:email=> 'public'}
    target_person.save!

    get "/api/v1/users/#{target_person.user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json["user"].has_key?("email")
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

end
