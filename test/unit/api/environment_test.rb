require_relative 'test_helper'

class SearchTest < ActiveSupport::TestCase

  def setup
    @person = create_user('testing').person
  end
  attr_reader :person

  should 'return the default environment' do
    default = Environment.default
    get "/api/v1/environment/default"
    json = JSON.parse(last_response.body)
    assert_equal default.id, json['id']
  end

  should 'return created environment' do
    other = fast_create(Environment)
    default = Environment.default
    assert_not_equal other.id, default.id
    get "/api/v1/environment/#{other.id}"
    json = JSON.parse(last_response.body)
    assert_equal other.id, json['id']
  end

  should 'return context environment' do
    contextEnv = fast_create(Environment)
    contextEnv.name = "example.org"
    contextEnv.save
    default = Environment.default
    assert_not_equal contextEnv.id, default.id
    get "/api/v1/environment/context"
    json = JSON.parse(last_response.body)
    assert_equal contextEnv.id, json['id']
  end  
end