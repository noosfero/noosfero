require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'

class AccessControlTest < Test::Unit::TestCase
  def test_can_have_role_in_respect_to_an_resource
    r = AccessControlTestResource.create(:name => 'bla')
    a = AccessControlTestAccessor.create(:name => 'ze')
    member_role = Role.create(:name => 'member', :permissions => ['bli'])
    r.affiliate(a, member_role)
    assert a.has_permission?('bli', r)
  end
end
