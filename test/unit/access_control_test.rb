
require_relative "../test_helper"

class AccessControlTest < ActiveSupport::TestCase

  include ActsAsAccessor

  should 'raise exception if parameter is not a profile' do
    assert_raises(TypeError) { member_relation_of(nil) }
  end

  should 'Verify relation among member and community' do
    person = fast_create(Person)
    community = fast_create(Community)
    assert_difference 'person.member_relation_of(community).count', 2 do
      community.add_member(person)
    end
  end

  should 'Member does not belong to community' do
    person = fast_create(Person)
    community = fast_create(Community)
    assert_nil person.member_since_date(community)
  end

  should 'Verify if enter date of member in community is available' do
    person = fast_create(Person)
    community = fast_create(Community)
    community.add_member(person)

    assert_instance_of Date, person.member_since_date(community)
  end

end
