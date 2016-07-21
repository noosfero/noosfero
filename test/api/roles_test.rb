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
    get "/api/v1/organizations/#{profile.id}/roles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [role1.id, role2.id], json['roles'].map {|r| r['id']}
  end
end
