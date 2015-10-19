# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper'

class UsersTest < ActiveSupport::TestCase

  def setup
    login_api
  end

  should 'list users' do
    get "/api/v1/users/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["users"].map { |a| a["login"] }, user.login
  end

  should 'create a user' do
    params[:user] = {:login => 'some', :password => '123456', :password_confirmation => '123456', :email => 'some@some.com'}
    post "/api/v1/users?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 'some', json['user']['login']
  end

  should 'not create duplicate user' do
    params[:lang] = :"pt-BR"
    params[:user] = {:login => 'some', :password => '123456', :password_confirmation => '123456', :email => 'some@some.com'}
    post "/api/v1/users?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 'some', json['user']['login']
    params[:user] = {:login => 'some', :password => '123456', :password_confirmation => '123456', :email => 'some@some.com'}
    post "/api/v1/users?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 'Username / Email já está em uso,e-Mail já está em uso', json['message']
  end

  should 'return 400 status for invalid user creation' do
    params[:user] = {:login => 'some'}
    post "/api/v1/users?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 400, last_response.status
  end

  should 'get user' do
    get "/api/v1/users/#{user.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal user.id, json['user']['id']
  end

  should 'list user permissions' do
    community = fast_create(Community)
    community.add_admin(person)
    get "/api/v1/users/#{user.id}/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["user"]["permissions"], community.identifier
  end

  should 'get logged user' do
    get "/api/v1/users/me?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal user.id, json['user']['id']
  end

end
