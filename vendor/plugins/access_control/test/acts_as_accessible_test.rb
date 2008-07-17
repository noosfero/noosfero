require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'

class ActsAsAccessibleTest < Test::Unit::TestCase

  def test_can_have_role_in_respect_to_an_resource
    r = AccessControlTestResource.create!(:name => 'bla')
    a = AccessControlTestAccessor.create!(:name => 'ze')
    member_role = Role.create!(:name => 'some new role for member', :permissions => ['bli'])
    r.affiliate(a, member_role)
    assert a.has_permission?('bli', r)
  end

  def test_can_unhave_a_role_in_respect_to_an_resource
    r = AccessControlTestResource.create(:name => 'bla')
    a = AccessControlTestAccessor.create(:name => 'ze')
    member_role = Role.create(:name => 'some wrenked role for member', :permissions => ['bli'])
    r.affiliate(a, member_role)
    assert a.has_permission?('bli', r)
    r.disaffiliate(a, member_role)
    r.reload; a.reload
    assert !a.has_permission?('bli', r)
  end

  def test_can_affiliate_more_than_one_role
    r = AccessControlTestResource.create(:name => 'bla')
    a = AccessControlTestAccessor.create(:name => 'ze')
    member_role = Role.create(:name => 'some member role', :permissions => ['bli'])
    admin_role = Role.create(:name => 'some admin role', :permissions => ['bla'])
    r.affiliate(a, [member_role, admin_role])
    assert a.has_permission?('bli', r)
    assert a.has_permission?('bla', r)
  end

  def test_do_not_list_removed_nil_members
    r = AccessControlTestResource.create(:name => 'bla')
    a = AccessControlTestAccessor.create(:name => 'ze')
    member_role = Role.create(:name => 'some tested member role', :permissions => ['bli'])
    r.affiliate(a, member_role)
    assert r.members.include?( a ), "expected #{r.inspect} to include #{a.inspect}"
    a.destroy
    r.reload
    assert !r.members.include?( a ), "expected #{r.inspect} to not include #{a.inspect}"
    assert !r.members.include?( nil ), "expected #{r.inspect} to not include nil"
  end

end
