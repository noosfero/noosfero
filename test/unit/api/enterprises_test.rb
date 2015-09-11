require_relative 'test_helper'

class EnterprisesTest < ActiveSupport::TestCase

  def setup
    Enterprise.delete_all
    login_api
  end

  should 'list only enterprises' do
    community = fast_create(Community) # should not list this community
    enterprise = fast_create(Enterprise, :public_profile => true)
    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json['enterprises'].map {|c| c['id']}, enterprise.id
    assert_not_includes json['enterprises'].map {|c| c['id']}, community.id
  end

  should 'list all enterprises' do
    enterprise1 = fast_create(Enterprise, :public_profile => true)
    enterprise2 = fast_create(Enterprise)
    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [enterprise1.id, enterprise2.id], json['enterprises'].map {|c| c['id']}
  end

  should 'not list invisible enterprises' do
    enterprise1 = fast_create(Enterprise)
    fast_create(Enterprise, :visible => false)

    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [enterprise1.id], json['enterprises'].map {|c| c['id']}
  end

  should 'not list private enterprises without permission' do
    enterprise1 = fast_create(Enterprise)
    fast_create(Enterprise, :public_profile => false)

    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [enterprise1.id], json['enterprises'].map {|c| c['id']}
  end

  should 'list private enterprise for members' do
    c1 = fast_create(Enterprise)
    c2 = fast_create(Enterprise, :public_profile => false)
    c2.add_member(person)

    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [c1.id, c2.id], json['enterprises'].map {|c| c['id']}
  end

  should 'get enterprise' do
    enterprise = fast_create(Enterprise)

    get "/api/v1/enterprises/#{enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal enterprise.id, json['enterprise']['id']
  end

  should 'not get invisible enterprise' do
    enterprise = fast_create(Enterprise, :visible => false)

    get "/api/v1/enterprises/#{enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['enterprise'].blank?
  end

  should 'not get private enterprises without permission' do
    enterprise = fast_create(Enterprise)
    fast_create(Enterprise, :public_profile => false)

    get "/api/v1/enterprises/#{enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal enterprise.id, json['enterprise']['id']
  end

  should 'get private enterprise for members' do
    enterprise = fast_create(Enterprise, :public_profile => false)
    enterprise.add_member(person)

    get "/api/v1/enterprises/#{enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal enterprise.id, json['enterprise']['id']
  end

  should 'list person enterprises' do
    enterprise = fast_create(Enterprise)
    fast_create(Enterprise)
    enterprise.add_member(person)

    get "/api/v1/people/#{person.id}/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [enterprise.id], json['enterprises'].map {|c| c['id']}
  end

  should 'not list person enterprises invisible' do
    c1 = fast_create(Enterprise)
    c2 = fast_create(Enterprise, :visible => false)
    c1.add_member(person)
    c2.add_member(person)

    get "/api/v1/people/#{person.id}/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [c1.id], json['enterprises'].map {|c| c['id']}
  end

end
