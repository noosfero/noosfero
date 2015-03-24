require File.dirname(__FILE__) + '/test_helper'

class PeopleTest < ActiveSupport::TestCase

  def setup
    login_api
  end


  should 'list all people' do
    person1 = fast_create(Person, :public_profile => true)
    person2 = fast_create(Person)
    get "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [person1.id, person2.id, person.id], json['people'].map {|c| c['id']}
  end

  should 'not list invisible people' do
    person1 = fast_create(Person)
    fast_create(Person, :visible => false)

    get "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [person1.id, person.id], json['people'].map {|c| c['id']}
  end

  should 'not list private people without permission' do
    person1 = fast_create(Person)
    fast_create(Person, :public_profile => false)

    get "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [person1.id, person.id], json['people'].map {|c| c['id']}
  end

  should 'list private person for friends' do
    p1 = fast_create(Person)
    p2 = fast_create(Person, :public_profile => false)
    person.add_friend(p2)
    p2.add_friend(person)

    get "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [p1.id, p2.id, person.id], json['people'].map {|c| c['id']}
  end

  should 'get person' do
    person = fast_create(Person)

    get "/api/v1/people/#{person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal person.id, json['person']['id']
  end

  should 'not get invisible person' do
    person = fast_create(Person, :visible => false)

    get "/api/v1/people/#{person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['person'].blank?
  end

  should 'not get private people without permission' do
    person = fast_create(Person)
    fast_create(Person, :public_profile => false)

    get "/api/v1/people/#{person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal person.id, json['person']['id']
  end

  should 'get private person for friends' do
    person = fast_create(Person, :public_profile => false)
    person.add_friend(person)

    get "/api/v1/people/#{person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal person.id, json['person']['id']
  end

  should 'list person friends' do
    p = fast_create(Person)
    fast_create(Person)
    person.add_friend(p)

    get "/api/v1/people/#{person.id}/friends?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [p.id], json['people'].map {|c| c['id']}
  end

  should 'not list person friends invisible' do
    p1 = fast_create(Person)
    p2 = fast_create(Person, :visible => false)
    person.add_friend(p1)
    person.add_friend(p2)

    get "/api/v1/people/#{person.id}/friends?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [p1.id], json['people'].map {|c| c['id']}
  end

end
