require File.dirname(__FILE__) + '/test_helper'

class PeopleTest < ActiveSupport::TestCase

  def setup
    Person.delete_all
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
    invisible_person = fast_create(Person, :visible => false)

    get "/api/v1/people?#{params.to_query}"
    assert_not_includes json_response_ids(:people), invisible_person.id
  end

  should 'not list private people without permission' do
    private_person = fast_create(Person, :public_profile => false)

    get "/api/v1/people?#{params.to_query}"
    assert_not_includes json_response_ids(:people), private_person.id
  end

  should 'list private person for friends' do
    p1 = fast_create(Person)
    p2 = fast_create(Person, :public_profile => false)
    person.add_friend(p2)
    p2.add_friend(person)

    get "/api/v1/people?#{params.to_query}"
    assert_includes json_response_ids(:people), p2.id
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
    private_person = fast_create(Person, :public_profile => false)

    get "/api/v1/people/#{private_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert json['person'].blank?
  end

  should 'get private person for friends' do
    private_person = fast_create(Person, :public_profile => false)
    person.add_friend(private_person)
    private_person.add_friend(person)

    get "/api/v1/people/#{private_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal private_person.id, json['person']['id']
  end

  should 'list person friends' do
    friend = fast_create(Person)
    person.add_friend(friend)
    friend.add_friend(person)

    get "/api/v1/people/#{friend.id}/friends?#{params.to_query}"
    assert_includes json_response_ids(:people), person.id
  end

  should 'not list person invisible friends' do
    friend = fast_create(Person)
    invisible_friend = fast_create(Person, :visible => false)
    person.add_friend(friend)
    person.add_friend(invisible_friend)
    friend.add_friend(person)
    invisible_friend.add_friend(person)

    get "/api/v1/people/#{person.id}/friends?#{params.to_query}"
    friends = json_response_ids(:people)
    assert_includes friends, friend.id
    assert_not_includes friends, invisible_friend.id
  end

end
