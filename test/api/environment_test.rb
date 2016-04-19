require_relative 'test_helper'

class EnvironmentTest < ActiveSupport::TestCase

  def setup
    @person = create_user('testing').person
  end
  attr_reader :person

  should 'return the default environment' do
    environment = Environment.default
    get "/api/v1/environment/default"
    json = JSON.parse(last_response.body)
    assert_equal environment.id, json['id']
  end

  should 'not return the default environment settings' do
    environment = Environment.default
    get "/api/v1/environment/default"
    json = JSON.parse(last_response.body)
    assert_equal environment.id, json['id']
    assert_nil json['settings']
  end

  def create_admin_user(env)
    admin_user = User.find_by(login: 'adminuser') || create_user('adminuser', :email => 'adminuser@noosfero.org', :password => 'adminuser', :password_confirmation => 'adminuser', :environment => env)
    admin_role = Role.find_by(name: 'admin_role') || Role.create!(:name => 'admin_role', :permissions => ['view_environment_admin_panel','edit_environment_features', 'edit_environment_design', 'manage_environment_categories', 'manage_environment_roles', 'manage_environment_trusted_sites', 'manage_environment_validators', 'manage_environment_users', 'manage_environment_organizations', 'manage_environment_templates', 'manage_environment_licenses', 'edit_appearance'])
    create(RoleAssignment, :accessor => admin_user.person, :role => admin_role, :resource => env) unless admin_user.person.role_assignments.map{|ra|[ra.role, ra.accessor, ra.resource]}.include?([admin_role, admin_user, env])
    admin_user.activate
    admin_user
  end

  def login_admin
    environment = Environment.default
    admin_user = create_admin_user(environment)
    params = {:login => "adminuser", :password => "adminuser"}
    post "/api/v1/login?#{params.to_query}"
    json = JSON.parse(last_response.body)
    private_token = json['user']["private_token"]
    assert !private_token.blank?
    assert_equal admin_user.private_token, private_token
    @params = {:private_token => private_token}
  end

  should 'return the default environment settings for admin' do
    login_admin
    environment = Environment.default
    get "/api/v1/environment/default?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal environment.id, json['id']
    assert_equal environment.settings, json['settings']
  end

  should 'return the default environment description' do
    environment = Environment.default
    get "/api/v1/environment/default"
    json = JSON.parse(last_response.body)
    assert_equal environment.description, json['description']
  end

  should 'return created environment' do
    environment = fast_create(Environment)
    default_env = Environment.default
    assert_not_equal environment.id, default_env.id
    get "/api/v1/environment/#{environment.id}"
    json = JSON.parse(last_response.body)
    assert_equal environment.id, json['id']
  end

  should 'return context environment' do
    context_env = fast_create(Environment)
    context_env.name = "example org"
    context_env.save
    context_env.domains<< Domain.new(:name => 'example.org')
    default_env = Environment.default
    assert_not_equal context_env.id, default_env.id
    get "/api/v1/environment/context"
    json = JSON.parse(last_response.body)
    assert_equal context_env.id, json['id']
  end  

end
