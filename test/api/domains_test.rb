require_relative 'test_helper'

class DomainsTest < ActiveSupport::TestCase

  def setup
    Domain.clear_cache
  end

  should 'return all domains' do
    Domain.delete_all
    environment = Environment.default
    profile = fast_create(Community, name: 'save-free-software')
    domain1 = create(Domain, name: 'test1.org', owner: environment)
    domain2 = create(Domain, name: 'test2.org', owner: profile)
    get "/api/v1/domains"
    json = JSON.parse(last_response.body)
    assert_equivalent ['test1.org', 'test2.org'], json.map { |d| d["name"]}
    assert_equivalent [environment.name, profile.name], json.map { |d| d["owner"]["name"]}
  end

  should 'return context domain' do
    context_env = fast_create(Environment)
    context_env.name = "example org"
    context_env.save
    context_env.domains << Domain.new(:name => 'example.org')
    default_env = Environment.default
    get "/api/v1/domains/context"
    json = JSON.parse(last_response.body)
    assert_equal context_env.domains.first.id, json['id']
  end

  should 'return domain by id' do
    environment = Environment.default
    domain = create(Domain, name: 'mynewdomain.org', owner: environment)
    get "/api/v1/domains/#{domain.id}"
    json = JSON.parse(last_response.body)
    assert_equal domain.id, json['id']
  end

  should 'paginate domains' do
    environment = Environment.default
    profile = fast_create(Community, name: 'save-free-software')
    1.upto(30){|n| create(Domain, name: "test#{n}.org", owner: profile)}
    get "/api/v1/domains"
    assert_equal 20, json_response_ids.length
  end


end
