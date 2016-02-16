require_relative 'test_helper'

class TasksTest < ActiveSupport::TestCase

  def setup
    login_api
    @person = user.person
    @community = fast_create(Community)
    @environment = Environment.default
  end

  attr_accessor :person, :community, :environment

  should 'list tasks of environment' do
    environment.add_admin(person)
    task = create(Task, :requestor => person, :target => environment)
    get "/api/v1/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["tasks"].map { |a| a["id"] }, task.id
  end

  should 'return environment task by id' do
    environment.add_admin(person)
    task = create(Task, :requestor => person, :target => environment)
    get "/api/v1/tasks/#{task.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal task.id, json["task"]["id"]
  end

  should 'not return environmet task if user has no permission to view it' do
    person = fast_create(Person)
    task = create(Task, :requestor => person, :target => environment)

    get "/api/v1/tasks/#{task.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

 #############################
 #     Community Tasks    #
 #############################

  should 'return task by community' do
    community = fast_create(Community)
    community.add_admin(person)

    task = create(Task, :requestor => person, :target => community)
    assert person.is_member_of?(community)

    get "/api/v1/communities/#{community.id}/tasks/#{task.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal task.id, json["task"]["id"]
  end

  should 'not return task by community if user has no permission to view it' do
    community = fast_create(Community)
    task = create(Task, :requestor => person, :target => community)
    assert !person.is_member_of?(community)

    get "/api/v1/communities/#{community.id}/tasks/#{task.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'create task in a community' do
    community = fast_create(Community)
    give_permission(person, 'perform_task', community)
    post "/api/v1/communities/#{community.id}/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_nil json["task"]["id"]
  end

  should 'create task defining the requestor as current profile logged in' do
    community = fast_create(Community)
    community.add_member(person)

    post "/api/v1/communities/#{community.id}/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal person, Task.last.requestor
  end

  should 'create task defining the target as the community' do
    community = fast_create(Community)
    community.add_member(person)

    post "/api/v1/communities/#{community.id}/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal community, Task.last.target
  end

 #############################
 #        Person Tasks       #
 #############################

  should 'return task by person' do
    task = create(Task, :requestor => person, :target => person)
    get "/api/v1/people/#{person.id}/tasks/#{task.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal task.id, json["task"]["id"]
  end

  should 'not return task by person if user has no permission to view it' do
    some_person = fast_create(Person)
    task = create(Task, :requestor => person, :target => some_person)

    get "/api/v1/people/#{some_person.id}/tasks/#{task.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'create task for person' do
    post "/api/v1/people/#{person.id}/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_nil json["task"]["id"]
  end

  should 'create task for another person' do
    some_person = fast_create(Person)
    post "/api/v1/people/#{some_person.id}/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal some_person, Task.last.target
  end

  should 'create task defining the target as a person' do
    post "/api/v1/people/#{person.id}/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal person, Task.last.target
  end

 #############################
 #      Enterprise Tasks     #
 #############################

  should 'return task by enterprise' do
    enterprise = fast_create(Enterprise)
    enterprise.add_admin(person)

    task = create(Task, :requestor => person, :target => enterprise)
    assert person.is_member_of?(enterprise)

    get "/api/v1/enterprises/#{enterprise.id}/tasks/#{task.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal task.id, json["task"]["id"]
  end

  should 'not return task by enterprise if user has no permission to view it' do
    enterprise = fast_create(Enterprise)
    task = create(Task, :requestor => person, :target => enterprise)
    assert !person.is_member_of?(enterprise)

    get "/api/v1/enterprises/#{enterprise.id}/tasks/#{task.id}?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'create task in a enterprise' do
    enterprise = fast_create(Enterprise)
    give_permission(person, 'perform_task', enterprise)
    post "/api/v1/enterprises/#{enterprise.id}/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_not_nil json["task"]["id"]
  end

  should 'create task defining the target as the enterprise' do
    enterprise = fast_create(Enterprise)
    enterprise.add_member(person)

    post "/api/v1/enterprises/#{enterprise.id}/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_equal enterprise, Task.last.target
  end
end
