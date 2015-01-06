require File.dirname(__FILE__) + '/test_helper'

class CommunitiesTest < ActiveSupport::TestCase

  def setup
    login_api
  end

  should 'list user communities' do
    community1 = fast_create(Community)
    fast_create(Community)
    community1.add_member(user.person)

    get "/api/v1/communities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [community1.id], json['communities'].map {|c| c['id']}
  end

  should 'list all communities' do
    community1 = fast_create(Community)
    community2 = fast_create(Community)

    get "/api/v1/communities/all?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [community1.id, community2.id], json['communities'].map {|c| c['id']}
  end

  should 'get community' do
    community = fast_create(Community)

    get "/api/v1/communities/#{community.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal community.id, json['community']['id']
  end

  should 'not list invisible communities' do
    community1 = fast_create(Community)
    fast_create(Community, :visible => false)

    get "/api/v1/communities/all?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [community1.id], json['communities'].map {|c| c['id']}
  end

  should 'not get invisible community' do
    community = fast_create(Community, :visible => false)

    get "/api/v1/communities/#{community.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['community'].blank?
  end

end
