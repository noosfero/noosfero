require_relative 'test_helper'

class EnvironmentTest < ActiveSupport::TestCase

  should 'return the default environment' do
    environment = Environment.default
    get "/api/v1/environment/default"
    json = JSON.parse(last_response.body)
    assert_equal environment.id, json['id']
  end

  should 'not return the default environment settings' do
    environment = Environment.default
    get "/api/v1/environment/default"
    json = JSON.parse(last_response.body)
    assert_equal environment.id, json['id']
    assert_nil json['settings']
  end

  should 'return the default environment settings for admin' do
    login_api
    environment = Environment.default
    environment.add_admin(person)
    get "/api/v1/environment/default?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal environment.id, json['id']
    assert_equal environment.settings, json['settings']
  end

  should 'not return the default environment settings for non admin users' do
    login_api
    environment = Environment.default
    get "/api/v1/environment/default?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal environment.id, json['id']
    assert_nil json['settings']
  end

  should 'return the default environment description' do
    environment = Environment.default
    get "/api/v1/environment/default"
    json = JSON.parse(last_response.body)
    assert_equal environment.description, json['description']
  end

  should 'return created environment' do
    environment = fast_create(Environment)
    default_env = Environment.default
    assert_not_equal environment.id, default_env.id
    get "/api/v1/environment/#{environment.id}"
    json = JSON.parse(last_response.body)
    assert_equal environment.id, json['id']
  end

  should 'return context environment' do
    context_env = fast_create(Environment)
    context_env.name = "example org"
    context_env.save
    context_env.domains<< Domain.new(:name => 'example.org')
    default_env = Environment.default
    assert_not_equal context_env.id, default_env.id
    get "/api/v1/environment/context"
    json = JSON.parse(last_response.body)
    assert_equal context_env.id, json['id']
  end  

end
