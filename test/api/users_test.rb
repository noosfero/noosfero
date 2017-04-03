# encoding: UTF-8
require_relative 'test_helper'

class UsersTest < ActiveSupport::TestCase

  def setup
    create_and_activate_user
  end

  should 'logger user list users' do
    login_api
    get "/api/v1/users/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json.map { |a| a["login"] }, user.login
  end

  should 'logger user get user info' do
    login_api
    get "/api/v1/users/#{user.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal user.id, json['id']
  end

  should 'logger user list user permissions' do
    login_api
    community = fast_create(Community)
    community.add_admin(person)
    get "/api/v1/users/#{user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["permissions"], community.identifier
  end

  should 'get logged user' do
    login_api
    get "/api/v1/users/me?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal user.id, json['id']
  end

  should 'not show permissions to logged user' do
    login_api
    target_user = User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment)
    get "/api/v1/users/#{target_user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    refute json.has_key?("permissions")
  end

  should 'logger user show permissions to self' do
    login_api
    get "/api/v1/users/#{user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json.has_key?("permissions")
  end

  should 'not show permissions to friend' do
    login_api
    target_person = User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment).person

    target_person.add_friend(person)
    person.add_friend(target_person)

    get "/api/v1/users/#{target_person.user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    refute json.has_key?("permissions")
  end

  should 'not show private attribute to logged user' do
    login_api
    target_user = User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment)

    get "/api/v1/users/#{target_user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_nil json['email']
    assert_nil json['person']
  end

  should 'show private attr to friend' do
    login_api
    target_person = User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment).person
    target_person.add_friend(person)
    person.add_friend(target_person)

    get "/api/v1/users/#{target_person.user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json.has_key?("email")
    assert_equal target_person.email, json["email"]
  end

  should 'show public attribute to logged user' do
    login_api
    target_person = User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment).person
    target_person.public_profile = true
    target_person.visible = true
    target_person.fields_privacy={:email=> 'public'}
    target_person.save!

    get "/api/v1/users/#{target_person.user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json.has_key?("email")
    assert_equal json["email"],target_person.email
  end

  should 'show public and private field to admin' do
    login_api
    Environment.default.add_admin(person)

    target_person = User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment).person
    target_person.fields_privacy={:email=> 'public'}
    target_person.save!

    get "/api/v1/users/#{target_person.user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json.has_key?("email")
    assert json.has_key?("permissions")
    assert json.has_key?("activated")
  end

  should 'show public fields to anonymous' do
    target_person = User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment).person
    target_person.fields_privacy={:email=> 'public'}
    target_person.public_profile = true
    target_person.visible = true
    target_person.save!

    get "/api/v1/users/#{target_person.user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json.has_key?("email")
  end

  should 'hide private fields to anonymous' do
    target_user = User.create!(:login => 'user1', :password => 'USER_PASSWORD', :password_confirmation => 'USER_PASSWORD', :email => 'test2@test.org', :environment => environment)

    get "/api/v1/users/#{target_user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    refute json.has_key?("permissions")
    refute json.has_key?("activated")
  end

  should 'change password successfully' do
    login_api
    params[:current_password] = 'testapi';
    params[:new_password] = 'USER_NEW_PASSWORD';
    params[:new_password_confirmation] = 'USER_NEW_PASSWORD';
    patch "/api/v1/users/#{user.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['success'], true
  end

end
