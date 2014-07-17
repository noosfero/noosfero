require File.dirname(__FILE__) + '/test_helper'

class RoleAssignmentTest < Test::Unit::TestCase

  def setup
    RoleAssignment.attr_accessible :is_global, :role, :accessor, :resource
  end

  def test_has_global_permission
    role = Role.create(:name => 'new_role', :permissions => ['permission'])
    ra = RoleAssignment.create(:role_id => role.id, :is_global => true)
    assert ra.has_permission?('permission', 'global')
    assert !ra.has_permission?('not_permitted', 'global')
  end  
  
  def test_has_global_permission_with_global_resource
    role = Role.create(:name => 'new_role', :permissions => ['permission'])
    accessor = AccessControlTestAccessor.create(:name => 'accessor')
    ra = RoleAssignment.create!(:role => role, :is_global => true, :accessor => accessor)
    assert ra.has_permission?('permission', 'global')
    assert !ra.has_permission?('not_permitted', 'global')
  end

  def test_has_specific_permission
    role = Role.create(:name => 'new_role', :permissions => ['permission'])
    accessor = AccessControlTestAccessor.create!(:name => 'accessor')
    resource_A = AccessControlTestResource.create!(:name => 'Resource A')
    resource_B = AccessControlTestResource.create!(:name => 'Resource B')
    ra = RoleAssignment.create!(:accessor => accessor, :role => role, :resource => resource_A)
    assert !ra.new_record?
    assert_equal role, ra.role
    assert_equal accessor, ra.accessor
    assert_equal resource_A, ra.resource
    assert ra.has_permission?('permission', resource_A)
    assert !ra.has_permission?('permission', resource_B)
  end
end
