require_relative 'test_helper'

class TolesTest < ActiveSupport::TestCase

  def setup
    create_and_activate_user
    login_api
    @environment = Environment.default
    @profile = fast_create(Organization)
  end

  attr_accessor :profile, :environment

  should 'list organization roles' do
    environment.roles.delete_all
    role1 = Role.create!(key: 'profile_administrator', name: 'admin', environment: environment)
    role2 = Role.new(key: 'profile_moderator', name: 'moderator', environment: environment)
    profile.custom_roles << role2
    get "/api/v1/profiles/#{profile.id}/roles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [role1.id, role2.id], json.map {|r| r['id']}
  end

  should 'return forbidden status when profile is not an organization' do
    get "/api/v1/profiles/#{person.id}/roles?#{params.to_query}"
    assert_equal 403, last_response.status
  end

  should 'list organization roles with assignments when pass person_id' do
    environment.roles.delete_all
    role1 = Role.create!(key: 'profile_administrator', name: 'admin', environment: environment)
    role2 = Role.new(key: 'profile_moderator', name: 'moderator', environment: environment)
    profile.custom_roles << role2
    profile.affiliate(person, [role2])
    params[:person_id] = person.id
    get "/api/v1/profiles/#{profile.id}/roles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert !json.find { |r|  r['key'] == 'profile_administrator' }['assigned']
    assert json.find { |r| r['key'] == 'profile_moderator' }['assigned']
  end

  should 'assign roles to a person into an organization' do
    environment.roles.delete_all
    role1 = Role.create!(key: 'profile_administrator', name: 'admin', environment: environment)
    role2 = Role.create!(key: 'profile_moderator', name: 'moderator', environment: environment)
    role3 = Role.create!(key: 'member', name: 'member', environment: environment)
    profile.affiliate(person, [role3])
    params[:person_id] = person.id
    params[:role_ids] = [role2.id]
    params[:remove_role_ids] = [role3.id]
    post "/api/v1/profiles/#{profile.id}/roles/assign?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal ['profile_moderator'], json.map { |r| r['key'] }
  end
end
