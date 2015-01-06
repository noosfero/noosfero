require File.dirname(__FILE__) + '/test_helper'

class PeopleTest < ActiveSupport::TestCase

  def setup
    login_api
  end

  should 'list persons' do
    person1 = fast_create(Person)
    person2 = fast_create(Person)

    get "/api/v1/people?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_includes json.map {|c| c['id']}, person1.id
    assert_includes json.map {|c| c['id']}, person2.id
  end

  should 'return one person by id' do
    person = fast_create(Person)

    get "/api/v1/people/#{person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal person.id, json['id']
  end

end
