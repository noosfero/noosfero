require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'

class ActAsAccessorTest < Test::Unit::TestCase

  def setup
    RoleAssignment.attr_accessible :accessor
  end

  def test_can_have_role_in_respect_to_an_resource
    res = AccessControlTestResource.create!(:name => 'bla')
    a = AccessControlTestAccessor.create!(:name => 'ze')
    role = Role.create!(:name => 'just_a_member', :permissions => ['bli'])
    assert a.add_role(role, res)
    assert a.has_permission?('bli', res)
  end

  def test_can_have_a_global_role
    r = AccessControlTestResource.create!(:name => 'bla')
    a = AccessControlTestAccessor.create!(:name => 'ze')
    member_role = Role.create!(:name => 'just_a_moderator', :permissions => ['bli'])
    assert a.add_role(member_role, r)
    assert a.has_permission?('bli', r)
  end

  def test_add_role
    res = AccessControlTestResource.create!(:name => 'bla')
    a = AccessControlTestAccessor.create!(:name => 'ze')
    role = Role.create!(:name => 'just_a_content_author', :permissions => ['bli'])
    assert a.add_role(role, res)
    assert a.role_assignments.map{|ra|[ra.role, ra.accessor, ra.resource]}.include?([role, a, res])
  end

  def test_remove_role
    res = AccessControlTestResource.create!(:name => 'bla')
    a = AccessControlTestAccessor.create!(:name => 'ze')
    role = Role.create!(:name => 'just_an_author', :permissions => ['bli'])
    ra = RoleAssignment.create!(:accessor => a, :role_id => role.id, :resource_id => res.id)

    assert a.role_assignments.include?(ra)
    a.remove_role(role, res)
    a.reload
    assert !a.role_assignments.map{|ra|[ra.role, ra.accessor, ra.resource]}.include?([role, a, res])
  end

  def test_do_not_add_role_twice
    res = AccessControlTestResource.create!(:name => 'bla')
    a = AccessControlTestAccessor.create!(:name => 'ze')
    role = Role.create!(:name => 'a_content_author', :permissions => ['bli'])
    assert a.add_role(role, res)
    assert !a.add_role(role, res)
    assert a.role_assignments.map{|ra|[ra.role, ra.accessor, ra.resource]}.include?([role, a, res])
  end

  def test_do_not_remove_inexistent_role
    res = AccessControlTestResource.create!(:name => 'bla')
    a = AccessControlTestAccessor.create!(:name => 'ze')
    role = Role.create!(:name => 'an_author', :permissions => ['bli'])

    assert !a.role_assignments.map{|ra|[ra.role, ra.accessor, ra.resource]}.include?([role, a, res]) 
    assert !a.remove_role(role, res)
  end

end
