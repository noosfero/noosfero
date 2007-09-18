require File.dirname(__FILE__) + '/../test_helper'

class RoleAssignmentTest < Test::Unit::TestCase
  all_fixtures
  
  def test_has_generic_permission
    role = Role.create(:name => 'new_role', :permissions => ['permission'])
    ra = RoleAssignment.create(:role => role)
    assert ra.has_permission?('permission', nil)
    assert !ra.has_permission?('not_permitted', nil)
  end

  def test_has_specific_permission
    role = Role.create(:name => 'new_role', :permissions => ['permission'])
    resource_A = Profile.create(:identifier => 'resource_a', :name => 'Resource A')
    resource_B = Profile.create(:identifier => 'resource_b', :name => 'Resource B')
    ra = RoleAssignment.create(:role => role, :resource => resource_A)
    assert ra.has_permission?('permission', resource_A)
    assert !ra.has_permission?('permission', resource_B)
  end
end
