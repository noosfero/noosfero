require_relative 'test_helper'

class EnterprisesTest < ActiveSupport::TestCase

  def setup
    Enterprise.delete_all
  end

  should 'logger user list only enterprises' do
    login_api
    community = fast_create(Community, :environment_id => environment.id) # should not list this community
    enterprise = fast_create(Enterprise, :environment_id => environment.id, :public_profile => true)
    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json['enterprises'].map {|c| c['id']}, enterprise.id
    assert_not_includes json['enterprises'].map {|c| c['id']}, community.id
  end

  should 'anonymous list only enterprises' do
    anonymous_setup
    community = fast_create(Community, :environment_id => environment.id) # should not list this community
    enterprise = fast_create(Enterprise, :environment_id => environment.id, :public_profile => true)
    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json['enterprises'].map {|c| c['id']}, enterprise.id
    assert_not_includes json['enterprises'].map {|c| c['id']}, community.id
  end

  should 'anonymous list all enterprises' do
    anonymous_setup
    enterprise1 = fast_create(Enterprise, :environment_id => environment.id, :public_profile => true)
    enterprise2 = fast_create(Enterprise, :environment_id => environment.id)
    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [enterprise1.id, enterprise2.id], json['enterprises'].map {|c| c['id']}
  end

  should 'logger user list all enterprises' do
    login_api
    enterprise1 = fast_create(Enterprise, :environment_id => environment.id, :public_profile => true)
    enterprise2 = fast_create(Enterprise, :environment_id => environment.id)
    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [enterprise1.id, enterprise2.id], json['enterprises'].map {|c| c['id']}
  end

  should 'not list invisible enterprises' do
    login_api
    enterprise1 = fast_create(Enterprise, :environment_id => environment.id)
    fast_create(Enterprise, :visible => false)

    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [enterprise1.id], json['enterprises'].map {|c| c['id']}
  end

  should 'not, anonymous list invisible enterprises' do
    anonymous_setup
    enterprise1 = fast_create(Enterprise, :environment_id => environment.id)
    fast_create(Enterprise, :visible => false)

    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [enterprise1.id], json['enterprises'].map {|c| c['id']}
  end

  should 'not, logger user list invisible enterprises' do
    login_api
    enterprise1 = fast_create(Enterprise, :environment_id => environment.id)
    fast_create(Enterprise, :visible => false)

    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [enterprise1.id], json['enterprises'].map {|c| c['id']}
  end

  should 'anonymous list private enterprises' do
    anonymous_setup
    enterprise1 = fast_create(Enterprise, :environment_id => environment.id)
    enterprise2 = fast_create(Enterprise, :environment_id => environment.id, :public_profile => false)

    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [enterprise1.id, enterprise2.id], json['enterprises'].map {|c| c['id']}
  end

  should 'logged user list private enterprises' do
    login_api
    enterprise1 = fast_create(Enterprise, :environment_id => environment.id)
    enterprise2 = fast_create(Enterprise, :environment_id => environment.id, :public_profile => false)

    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [enterprise1.id, enterprise2.id], json['enterprises'].map {|c| c['id']}
  end

  should 'logged user list private enterprise for members' do
    login_api
    c1 = fast_create(Enterprise, :environment_id => environment.id)
    c2 = fast_create(Enterprise, :environment_id => environment.id, :public_profile => false)
    c2.add_member(person)

    get "/api/v1/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [c1.id, c2.id], json['enterprises'].map {|c| c['id']}
  end

  should 'anonymous get enterprise' do
    anonymous_setup
    enterprise = fast_create(Enterprise, :environment_id => environment.id)

    get "/api/v1/enterprises/#{enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal enterprise.id, json['enterprise']['id']
  end

  should 'logged user get enterprise' do
    login_api
    enterprise = fast_create(Enterprise, :environment_id => environment.id)

    get "/api/v1/enterprises/#{enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal enterprise.id, json['enterprise']['id']
  end

  should 'not, logger user get invisible enterprise' do
    login_api
    enterprise = fast_create(Enterprise, :visible => false)

    get "/api/v1/enterprises/#{enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['enterprise'].blank?
  end

  should 'not, anonymous get invisible enterprise' do
    anonymous_setup
    enterprise = fast_create(Enterprise, :visible => false)

    get "/api/v1/enterprises/#{enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['enterprise'].blank?
  end

  should 'not get private enterprises without permission' do
    login_api
    enterprise = fast_create(Enterprise, :environment_id => environment.id)
    fast_create(Enterprise, :environment_id => environment.id, :public_profile => false)

    get "/api/v1/enterprises/#{enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal enterprise.id, json['enterprise']['id']
  end

  should 'not, anonymous get private enterprises' do
    anonymous_setup
    enterprise = fast_create(Enterprise, :environment_id => environment.id)
    fast_create(Enterprise, :environment_id => environment.id, :public_profile => false)

    get "/api/v1/enterprises/#{enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal enterprise.id, json['enterprise']['id']
  end

  should 'get private enterprise for members' do
    login_api
    enterprise = fast_create(Enterprise, :public_profile => false)
    enterprise.add_member(person)

    get "/api/v1/enterprises/#{enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal enterprise.id, json['enterprise']['id']
  end

  should 'list person enterprises' do
    login_api
    enterprise = fast_create(Enterprise, :environment_id => environment.id)
    fast_create(Enterprise, :environment_id => environment.id)
    enterprise.add_member(person)

    get "/api/v1/people/#{person.id}/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [enterprise.id], json['enterprises'].map {|c| c['id']}
  end

  should 'not list person enterprises invisible' do
    login_api
    c1 = fast_create(Enterprise, :environment_id => environment.id)
    c2 = fast_create(Enterprise, :environment_id => environment.id, :visible => false)
    c1.add_member(person)
    c2.add_member(person)

    get "/api/v1/people/#{person.id}/enterprises?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [c1.id], json['enterprises'].map {|c| c['id']}
  end

  should 'display public custom fields to anonymous' do
    anonymous_setup
    CustomField.create!(:name => "Rating", :format => "string", :customized_type => "Enterprise", :active => true, :environment => Environment.default)
    some_enterprise = fast_create(Enterprise)
    some_enterprise.custom_values = { "Rating" => { "value" => "Five stars", "public" => "true"} }
    some_enterprise.save!

    get "/api/v1/enterprises/#{some_enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['enterprise']['additional_data'].has_key?('Rating')
    assert_equal "Five stars", json['enterprise']['additional_data']['Rating']
  end

  should 'not display public custom fields to anonymous' do
    anonymous_setup
    CustomField.create!(:name => "Rating", :format => "string", :customized_type => "Enterprise", :active => true, :environment => Environment.default)
    some_enterprise = fast_create(Enterprise)
    some_enterprise.custom_values = { "Rating" => { "value" => "Five stars", "public" => "false"} }
    some_enterprise.save!

    get "/api/v1/enterprises/#{some_enterprise.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    refute json['enterprise']['additional_data'].has_key?('Rating')
  end

end
