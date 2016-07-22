require_relative 'test_helper'

class TasksTest < ActiveSupport::TestCase

  def setup
    create_and_activate_user
    login_api
    @community = fast_create(Community)
    @environment = Environment.default
  end

  attr_accessor :person, :community, :environment

  should 'list environment tasks for admin user' do
    environment.add_admin(person)
    task = create(Task, :requestor => person, :target => environment)
    get "/api/v1/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["tasks"].map { |a| a["id"] }, task.id
  end

  should 'not list tasks of environment for unlogged users' do
    logout_api
    environment.add_admin(person)
    task = create(Task, :requestor => person, :target => environment)
    get "/api/v1/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 401, last_response.status
  end

  should 'return environment task by id' do
    environment.add_admin(person)
    task = create(Task, :requestor => person, :target => environment)
    get "/api/v1/tasks/#{task.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal task.id, json["task"]["id"]
  end

  should 'not return environment task by id for unlogged users' do
    logout_api
    environment.add_admin(person)
    task = create(Task, :requestor => person, :target => environment)
    get "/api/v1/tasks/#{task.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal 401, last_response.status
  end

  should 'not return environmet task if user has no permission to view it' do
    person = fast_create(Person)
    task = create(Task, :requestor => person, :target => environment)

    get "/api/v1/tasks/#{task.id}?#{params.to_query}"
    assert_equal 404, last_response.status
  end

  should 'find the current user task even it is finished' do
    t3 = create(Task, :requestor => person, :target => person)
    t4 = create(Task, :requestor => person, :target => person, :status => Task::Status::FINISHED)

    get "/api/v1/tasks/#{t4.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal t4.id, json["task"]["id"]
  end

  should 'find the current user task even it is for community' do
    community = fast_create(Community)
    community.add_admin(person)
    t2 = create(Task, :requestor => person, :target => community)

    t3 = create(Task, :requestor => person, :target => person)

    get "/api/v1/tasks/#{t2.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal t2.id, json["task"]["id"]
  end

  should 'find the current user task even it is for environment' do
    environment.add_admin(person)
    t1 = create(Task, :requestor => person, :target => environment)

    t3 = create(Task, :requestor => person, :target => person)

    get "/api/v1/tasks/#{t1.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal t1.id, json["task"]["id"]
  end


  should 'list all tasks of user' do
    environment.add_admin(person)
    t1 = create(Task, :requestor => person, :target => environment)

    community = fast_create(Community)
    community.add_admin(person)
    t2 = create(Task, :requestor => person, :target => community)

    t3 = create(Task, :requestor => person, :target => person)
    t4 = create(Task, :requestor => person, :target => person, :status => Task::Status::FINISHED)

    get "/api/v1/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [t1.id, t2.id, t3.id, t4.id], json["tasks"].map { |a| a["id"] }
  end

  should 'list all pending tasks of user' do
    environment.add_admin(person)
    t1 = create(Task, :requestor => person, :target => environment, :status => Task::Status::ACTIVE)

    community = fast_create(Community)
    community.add_admin(person)
    t2 = create(Task, :requestor => person, :target => community, :status => Task::Status::ACTIVE)

    t3 = create(Task, :requestor => person, :target => person, :status => Task::Status::ACTIVE)
    t4 = create(Task, :requestor => person, :target => person, :status => Task::Status::FINISHED)

    get "/api/v1/tasks?#{params.merge(:status => Task::Status::ACTIVE).to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [t1.id, t2.id, t3.id], json["tasks"].map { |a| a["id"] }
  end


  should 'list tasks with pagination' do
    Task.destroy_all
    t1 = create(Task, :requestor => person, :target => person)
    t2 = create(Task, :requestor => person, :target => person)

    params[:page] = 1
    params[:per_page] = 1
    get "/api/v1/tasks/?#{params.to_query}"
    json_page_one = JSON.parse(last_response.body)

    params[:page] = 2
    params[:per_page] = 1
    get "/api/v1/tasks/?#{params.to_query}"
    json_page_two = JSON.parse(last_response.body)

    assert_includes json_page_one["tasks"].map { |a| a["id"] }, t2.id
    assert_not_includes json_page_one["tasks"].map { |a| a["id"] }, t1.id

    assert_includes json_page_two["tasks"].map { |a| a["id"] }, t1.id
    assert_not_includes json_page_two["tasks"].map { |a| a["id"] }, t2.id
  end

  should 'list tasks with timestamp' do
    t1 = create(Task, :requestor => person, :target => person)
    t2 = create(Task, :requestor => person, :target => person, :created_at => Time.zone.now)

    t1.created_at = Time.zone.now + 3.hours
    t1.save!


    params[:timestamp] = Time.zone.now + 1.hours
    get "/api/v1/tasks/?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert_includes json["tasks"].map { |a| a["id"] }, t1.id
    assert_not_includes json["tasks"].map { |a| a["id"] }, t2.id
  end

  task_actions=%w[finish cancel]
  task_actions_state={"finish"=>"FINISHED","cancel"=>"CANCELLED"}
  task_actions.each do |action|
    should "person be able to #{action} his own task" do
      person1 = fast_create(Person)
      task = create(Task, :requestor => person1, :target => person)
      put "/api/v1/tasks/#{task.id}/#{action}?#{params.to_query}"
      assert_equal person.reload.id, task.reload.closed_by_id
      assert_equal "Task::Status::#{task_actions_state[action]}".constantize, task.reload.status
    end

    should "person be able to #{action} environment task if it's admin user" do
      environment = Environment.default
      environment.add_admin(person)
      task = create(Task, :requestor => person, :target => environment)
      put "/api/v1/tasks/#{task.id}/#{action}?#{params.to_query}"
      assert_equal person.reload.id, task.reload.closed_by_id
      assert_equal "Task::Status::#{task_actions_state[action]}".constantize, task.reload.status
    end

    should "person be able to #{action} community task if it has permission on it" do
      community = fast_create(Community)
      community.add_member(person)
      give_permission(person, 'perform_task', community)
      task = create(Task, :requestor => person, :target => community)
      put "/api/v1/tasks/#{task.id}/#{action}?#{params.to_query}"
      assert_equal person.reload.id, task.reload.closed_by_id
      assert_equal "Task::Status::#{task_actions_state[action]}".constantize, task.reload.status
    end

    should "person not be able to #{action} community task if it has no permission on it" do
      community = fast_create(Community)
      community.add_member(person)
      task = create(Task, :requestor => person, :target => community)
      put "/api/v1/tasks/#{task.id}/#{action}?#{params.to_query}"
      assert_equal person.reload.id, task.reload.closed_by_id
      assert_equal "Task::Status::#{task_actions_state[action]}".constantize, task.reload.status
    end

    should "person not be able to #{action} other person's task" do
      user = fast_create(User)
      person1 = fast_create(Person, :user_id => user)
      task = create(Task, :requestor => person, :target => person1)
      put "/api/v1/tasks/#{task.id}/#{action}?#{params.to_query}"
      assert_nil task.reload.closed_by_id
      assert_equal Task::Status::ACTIVE, task.status
    end

    should "person be able to #{action} a task with parameters" do
      person1 = fast_create(Person)
      task = create(Task, :requestor => person1, :target => person)
      params[:task] = {reject_explanation: "reject explanation"}
      put "/api/v1/tasks/#{task.id}/#{action}?#{params.to_query}"
      assert_equal "Task::Status::#{task_actions_state[action]}".constantize, task.reload.status
      assert_equal "reject explanation", task.reload.reject_explanation
    end

    should "not update a forbidden parameter when #{action} a task" do
      person1 = fast_create(Person)
      person2 = fast_create(Person)
      task = create(Task, :requestor => person1, :target => person)
      params[:task] = { requestor: {id: person2.id} }
      put "/api/v1/tasks/#{task.id}/#{action}?#{params.to_query}"
      assert_equal 500, last_response.status
    end
  end

  #################################################
  #     Person, Community and Enterprise Tasks    #
  #################################################

  [Person, Community, Enterprise].map do |profile_class|
    define_method "test_should_return_task_by_#{profile_class.name.underscore}" do
      target = profile_class == Person ? person : fast_create(profile_class)
      target.add_admin(person) if target.respond_to?('add_admin')

      task = create(Task, :requestor => person, :target => target)
      get "/api/v1/#{profile_class.name.underscore.pluralize}/#{target.id}/tasks/#{task.id}?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal task.id, json["task"]["id"]
    end

    define_method "test_should_not_return_task_ by#{profile_class.name.underscore}_for_unlogged_users" do
      logout_api
      target = profile_class == Person ? person : fast_create(profile_class)
      target.add_admin(person) if target.respond_to?('add_admin')

      task = create(Task, :requestor => person, :target => target)
      get "/api/v1/#{profile_class.name.underscore.pluralize}/#{target.id}/tasks/#{task.id}?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal 401, last_response.status
    end

    define_method "test_should_not_return_task_by_#{profile_class.name.underscore}_if_user_has_no_permission_to_view_it" do
      target = fast_create(profile_class)
      task = create(Task, :requestor => person, :target => target)
  
      get "/api/v1/#{profile_class.name.underscore.pluralize}/#{target.id}/tasks/#{task.id}?#{params.to_query}"
      assert_equal 403, last_response.status
    end

    define_method "test_should_create_task_for_#{profile_class.name.underscore}" do
      target = profile_class == Person ? person : fast_create(profile_class)
      Person.any_instance.expects(:has_permission?).with(:perform_task, target).returns(true)

      post "/api/v1/#{profile_class.name.underscore.pluralize}/#{target.id}/tasks?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_not_nil json["task"]["id"]
    end

    define_method "test_should_not_create_task_for_#{profile_class.name.underscore}_person_has_no_permission" do
      target = fast_create(profile_class)

      post "/api/v1/#{profile_class.name.underscore.pluralize}/#{target.id}/tasks?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal 403, last_response.status
    end

    define_method "test_should_not_create_task_in_#{profile_class.name.underscore}_for_unlogged_users" do
      logout_api
      target = profile_class == Person ? person : fast_create(profile_class)
      Person.any_instance.stubs(:has_permission?).with(:perform_task, target).returns(true)

      post "/api/v1/#{profile_class.name.underscore.pluralize}/#{target.id}/tasks?#{params.to_query}"

      json = JSON.parse(last_response.body)
      assert_equal 401, last_response.status
    end

    define_method "test_should_create_task_defining_the_target_as_a_#{profile_class.name.underscore}" do
      target = profile_class == Person ? person : fast_create(profile_class)
      Person.any_instance.stubs(:has_permission?).with(:perform_task, target).returns(true)

      post "/api/v1/#{profile_class.name.underscore.pluralize}/#{target.id}/tasks?#{params.to_query}"
      json = JSON.parse(last_response.body)
  
      assert_equal target, Task.last.target
    end

    define_method "test_should_create_task_on_#{profile_class.name.underscore}_defining_the_requestor_as_current_profile_logged_in" do
      target = profile_class == Person ? person : fast_create(profile_class)
      Person.any_instance.stubs(:has_permission?).with(:perform_task, target).returns(true)
  
      post "/api/v1/#{profile_class.name.underscore.pluralize}/#{target.id}/tasks?#{params.to_query}"
      json = JSON.parse(last_response.body)
  
      assert_equal person, Task.last.requestor
    end
  end

  should 'list all tasks of user in people context' do
    environment.add_admin(person)
    t1 = create(Task, :requestor => person, :target => environment)

    community = fast_create(Community)
    community.add_admin(person)
    t2 = create(Task, :requestor => person, :target => community)

    t3 = create(Task, :requestor => person, :target => person)

    get "/api/v1/people/#{person.id}/tasks?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [t1.id, t2.id, t3.id], json["tasks"].map { |a| a["id"] }
  end

  should 'list all pending tasks of user in people context' do
    environment.add_admin(person)
    t1 = create(Task, :requestor => person, :target => environment)
    t2 = create(Task, :requestor => person, :target => environment, :status => Task::Status::FINISHED )

    community = fast_create(Community)
    community.add_admin(person)
    t3 = create(Task, :requestor => person, :target => community)
    t4 = create(Task, :requestor => person, :target => community, :status => Task::Status::FINISHED)

    t5 = create(Task, :requestor => person, :target => person)
    t6 = create(Task, :requestor => person, :target => person, :status => Task::Status::FINISHED)

    get "/api/v1/people/#{person.id}/tasks?#{params.merge(:status => Task::Status::ACTIVE).to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [t1.id, t3.id, t5.id], json["tasks"].map { |a| a["id"] }
  end

end
