require_relative "../test_helper"

class RoleAssignmentExtTest < ActiveSupport::TestCase
  should 'increase organization members_count only on the first role_assignment' do
    role1 = Role.create!(:name => 'role1')
    role2 = Role.create!(:name => 'role2')
    member = create_user('person').person
    organization = Organization.create!(:name => 'Organization', :identifier => 'organization')
    assert_difference 'organization.members_count', 1 do
      create(RoleAssignment, :accessor => member, :resource => organization, :role => role1)
      create(RoleAssignment, :accessor => member, :resource => organization, :role => role2)
      organization.reload
    end
  end

  should 'decrease organization members_count only on the last role_assignment' do
    role1 = Role.create!(:name => 'role1')
    role2 = Role.create!(:name => 'role2')
    member = create_user('person').person
    organization = Organization.create!(:name => 'Organization', :identifier => 'organization')
    create(RoleAssignment, :accessor => member, :resource => organization, :role => role1)
    create(RoleAssignment, :accessor => member, :resource => organization, :role => role2)
    organization.reload
    assert_difference 'organization.members_count', -1 do
      organization.role_assignments.destroy_all
      organization.reload
    end
  end
end
