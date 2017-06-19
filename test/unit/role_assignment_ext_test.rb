require_relative "../test_helper"

class RoleAssignmentExtTest < ActiveSupport::TestCase

  def setup
    @role1 = Role.create!(:name => 'role1')
    @role2 = Role.create!(:name => 'role2')
    @member = create_user('person').person
    @organization = Organization.create!(:name => 'Organization', :identifier => 'organization')
  end

  should 'increase organization members_count only on the first role_assignment' do
    assert_difference '@organization.members_count', 1 do
      create(RoleAssignment, :accessor => @member, :resource => @organization, :role => @role1)
      create(RoleAssignment, :accessor => @member, :resource => @organization, :role => @role2)
      @organization.reload
    end
  end

  should 'decrease organization members_count only on the last role_assignment' do
    create(RoleAssignment, :accessor => @member, :resource => @organization, :role => @role1)
    create(RoleAssignment, :accessor => @member, :resource => @organization, :role => @role2)
    @organization.reload
    assert_difference '@organization.members_count', -1 do
      @organization.role_assignments.destroy_all
      @organization.reload
    end
  end

  should 'create a follow relationship only if the role key is in the list' do
    member_role = Role.create!(:name => 'member')
    Person.any_instance.expects(:follow).once

    create(RoleAssignment, :accessor => @member, :resource => @organization, :role => @role1)
    create(RoleAssignment, :accessor => @member, :resource => @organization, :role => member_role)
  end

  should 'remove the follow relationship only once if the role key is in the list' do
    member_role = Role.create!(:name => 'member')
    admin_role = Role.create!(:name => 'admin')

    ra1 = create(RoleAssignment, :accessor => @member, :resource => @organization, :role => admin_role)
    ra2 = create(RoleAssignment, :accessor => @member, :resource => @organization, :role => member_role)

    Person.any_instance.expects(:unfollow).once
    ra1.destroy
    ra2.destroy
  end
end
