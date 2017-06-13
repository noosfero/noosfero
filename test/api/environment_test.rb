require_relative 'test_helper'

class EnvironmentTest < ActiveSupport::TestCase

  def setup
    create_and_activate_user
  end

  ENDPOINTS = ['environment', 'environments']

  ENDPOINTS.map do |endpoint|

    define_method "test_should_return_the_#{endpoint}_default_environment" do
      environment = Environment.default
      get "/api/v1/#{endpoint}/default"
      json = JSON.parse(last_response.body)
      assert_equal environment.id, json['id']
    end

    define_method "test_should_not_return_the_default_environment_settings_for_#{endpoint}" do
      environment = Environment.default
      get "/api/v1/#{endpoint}/default"
      json = JSON.parse(last_response.body)
      assert_equal environment.id, json['id']
      assert_nil json['settings']
    end

    define_method "test_should_return_the_default_environment_settings_for_admin_for_#{endpoint}" do
      login_api
      environment = Environment.default
      environment.add_admin(person)
      get "/api/v1/#{endpoint}/default?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal environment.id, json['id']
      assert_equal environment.settings, json['settings']
    end

    define_method "test_should_not_return_the_default_environment_settings_for_non_admin_users_for_#{endpoint}" do
      login_api
      environment = Environment.default
      get "/api/v1/#{endpoint}/default?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal environment.id, json['id']
      assert_nil json['settings']
    end

    define_method "test_should_return_the_default_environment_descriptionfor_#{endpoint}" do
      environment = Environment.default
      get "/api/v1/#{endpoint}/default"
      json = JSON.parse(last_response.body)
      assert_equal environment.description, json['description']
    end

    define_method "test_should_return_created_environment_for_#{endpoint}" do
      environment = fast_create(Environment)
      default_env = Environment.default
      assert_not_equal environment.id, default_env.id
      get "/api/v1/#{endpoint}/#{environment.id}"
      json = JSON.parse(last_response.body)
      assert_equal environment.id, json['id']
    end

    define_method "test_should_return_context_environment_for_#{endpoint}" do
      context_env = fast_create(Environment)
      context_env.name = "example org"
      context_env.save
      context_env.domains<< Domain.new(:name => 'example.org')
      default_env = Environment.default
      assert_not_equal context_env.id, default_env.id
      get "/api/v1/#{endpoint}/context"
      json = JSON.parse(last_response.body)
      assert_equal context_env.id, json['id']
    end

    define_method "test_should_return_no_permissions_for_the_current_person_that_has_no_role_in_the_environment_for_#{endpoint}" do
      login_api
      environment = Environment.default
      get "/api/v1/#{endpoint}/default?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal [], json['permissions']
    end

    define_method "test_should_return_permissions_for_the_current_person_in_the_environment_for_#{endpoint}" do
      login_api
      environment = Environment.default
      environment.add_admin(person)
      get "/api/v1/#{endpoint}/default?#{params.to_query}"
      json = JSON.parse(last_response.body)
      assert_equal environment.permissions_for(person), json['permissions']
    end

    define_method "test_should_update_environment_for_#{endpoint}" do
      login_api
      environment = Environment.default
      environment.add_admin(person)
      params[:environment] = {layout_template: "leftbar"}
      post "/api/v1/#{endpoint}/#{environment.id}?#{params.to_query}"
      assert_equal "leftbar", environment.reload.layout_template
    end

    define_method "test_should_forbid_update_for_non_admin_users_for_#{endpoint}" do
      login_api
      environment = Environment.default
      params[:environment] = {layout_template: "leftbar"}
      post "/api/v1/#{endpoint}/#{environment.id}?#{params.to_query}"
      assert_equal 403, last_response.status
      assert_equal "default", environment.reload.layout_template
    end

    define_method "test_should_return_signup_person_fields_for_#{endpoint}" do
      environment = Environment.default
      fields = ['field1', 'field2']
      Environment.any_instance.expects(:signup_person_fields).returns(fields)
      get "/api/v1/#{endpoint}/signup_person_fields"
      json = JSON.parse(last_response.body)
      assert_equal fields, json
    end

  end

  should 'return the default environment with status OK' do
    environment = Environment.default
    get "/api/v1/environments/default"
    assert_equal Api::Status::Http::OK, last_response.status
  end

  should 'return the context environment with status OK' do
    environment = Environment.default
    get "/api/v1/environments/context"
    assert_equal Api::Status::Http::OK, last_response.status
  end

  should 'return created environment with status OK' do
    environment = fast_create(Environment)
    default_env = Environment.default
    assert_not_equal environment.id, default_env.id
    get "/api/v1/environments/#{environment.id}"
    assert_equal Api::Status::Http::OK, last_response.status
  end

  should 'return signup_person_fields with status OK' do
    environment = Environment.default
    fields = ['field1', 'field2']
    Environment.any_instance.expects(:signup_person_fields).returns(fields)
    get "/api/v1/environments/signup_person_fields"
    assert_equal Api::Status::Http::OK, last_response.status
  end

  should 'update environment with status CREATED' do
    login_api
    environment = Environment.default
    environment.add_admin(person)
    params[:environment] = {layout_template: "leftbar"}
    post "/api/v1/environments/#{environment.id}?#{params.to_query}"
    assert_equal Api::Status::Http::CREATED, last_response.status
  end

  should 'return the default environment with status DEPRECATED' do
    environment = Environment.default
    get "/api/v1/environment/default"
    assert_equal Api::Status::DEPRECATED, last_response.status
  end

  should 'return the context environment with status DEPRECATED' do
    environment = Environment.default
    get "/api/v1/environment/context"
    assert_equal Api::Status::DEPRECATED, last_response.status
  end

  should 'return created environment with status DEPRECATED' do
    environment = fast_create(Environment)
    default_env = Environment.default
    assert_not_equal environment.id, default_env.id
    get "/api/v1/environment/#{environment.id}"
    assert_equal Api::Status::DEPRECATED, last_response.status
  end

  should 'return signup_person_fields with status DEPRECATED' do
    environment = Environment.default
    fields = ['field1', 'field2']
    Environment.any_instance.expects(:signup_person_fields).returns(fields)
    get "/api/v1/environment/signup_person_fields"
    assert_equal Api::Status::DEPRECATED, last_response.status
  end

  should 'update environment with status DEPRECATED' do
    login_api
    environment = Environment.default
    environment.add_admin(person)
    params[:environment] = {layout_template: "leftbar"}
    post "/api/v1/environment/#{environment.id}?#{params.to_query}"
    assert_equal Api::Status::DEPRECATED, last_response.status
  end

  should 'add block in environment' do
    login_api
    environment = Environment.default
    environment.add_admin(person)
    environment.boxes << Box.new

    block = { title: 'test', type: RawHTMLBlock }
    params[:environment] = { boxes_attributes: [{id: environment.boxes.first.id, blocks_attributes: [block] }] }
    post "/api/v1/environments/#{environment.id}?#{params.to_query}"
    assert_equal ['test'], environment.reload.blocks.map(&:title)
    assert_equal ['RawHTMLBlock'], environment.reload.blocks.map(&:type)
  end

  should 'remove blocks from environment' do
    login_api
    environment = Environment.default
    environment.add_admin(person)
    environment.boxes << Box.new
    environment.boxes.first.blocks << Block.new(title: 'test')
    block = { id: environment.boxes.first.blocks.first.id, _destroy: true }
    params[:environment] = { boxes_attributes: [{id: environment.boxes.first.id, blocks_attributes: [block] }] }
    post "/api/v1/environments/#{environment.id}?#{params.to_query}"
    assert environment.reload.blocks.empty?
  end

  should 'edit block from environment' do
    login_api
    environment = Environment.default
    environment.add_admin(person)
    environment.boxes << Box.new
    environment.boxes.first.blocks << Block.new(title: 'test')

    block = { id: environment.boxes.first.blocks.first.id, title: 'test 2' }
    params[:environment] = { boxes_attributes: [{id: environment.boxes.first.id, blocks_attributes: [block] }] }
    post "/api/v1/environments/#{environment.id}?#{params.to_query}"
    assert_equal ['test 2'], environment.reload.blocks.map(&:title)
  end

  should 'edit block position from environment' do
    login_api
    environment = Environment.default
    environment.add_admin(person)
    environment.boxes << Box.new
    environment.boxes.first.blocks << Block.new(title: 'test')

    block = { id: environment.boxes.first.blocks.first.id, position: 2 }
    params[:environment] = { boxes_attributes: [{id: environment.boxes.first.id, blocks_attributes: [block] }] }
    post "/api/v1/environments/#{environment.id}?#{params.to_query}"
    assert_equal [2], environment.reload.blocks.map(&:position)
  end

  should 'list available blocks of environment' do
    environment = Environment.default
    person = create_user('mytestuser').person
    assert_includes environment.available_blocks(person), CommunitiesBlock
  end

end
