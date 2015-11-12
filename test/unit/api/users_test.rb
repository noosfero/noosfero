# encoding: UTF-8
require_relative 'test_helper'

class UsersTest < ActiveSupport::TestCase

  def setup
    login_api
  end

  should 'list users' do
    get "/api/v1/users/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["users"].map { |a| a["login"] }, user.login
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
