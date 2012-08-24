require File.dirname(__FILE__) + '/../../../../test/test_helper'

class SubOrganizationsTest < ActiveSupport::TestCase

  def setup
    @plugin = SubOrganizationsPlugin.new
  end

  attr_reader :plugin

  should 'include sub-organizations members in the parent organization' do
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)
    org3 = fast_create(Organization)
    member1 = fast_create(Person)
    member2 = fast_create(Person)
    member3 = fast_create(Person)
    member4 = fast_create(Person)
    member5 = fast_create(Person)
    member6 = fast_create(Person)
    member7 = fast_create(Person)
    org1.add_member(member1)
    org2.add_member(member2)
    org2.add_member(member3)
    org3.add_member(member4)
    org3.add_member(member5)
    SubOrganizationsPlugin::Relation.create!(:parent => org1, :child => org2)
    SubOrganizationsPlugin::Relation.create!(:parent => org1, :child => org3)

    org1_members = plugin.organization_members(org1)

    assert_equal ActiveRecord::NamedScope::Scope, org1_members.class
    assert_not_includes org1_members, member1
    assert_includes org1_members, member2
    assert_includes org1_members, member3
    assert_includes org1_members, member4
    assert_includes org1_members, member5
    assert_not_includes org1_members, member6
    assert_not_includes org1_members, member7

    org2_members = plugin.organization_members(org2)
    org3_members = plugin.organization_members(org3)

    assert org2_members.blank?
    assert org3_members.blank?
  end

  should 'grant permission that user has on parent organizations over children orgnaizations' do
    person = create_user('admin-user').person
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)
    SubOrganizationsPlugin::Relation.add_children(org1,org2)
    person.stubs('has_permission_without_plugins?').with(:make_ice_cream, org1).returns(true)
    person.stubs('has_permission_without_plugins?').with(:make_ice_cream, org2).returns(false)

    assert plugin.has_permission?(person, :make_ice_cream, org2)
  end

  should 'not crash if receives an environment as target of has permission' do
    assert_nothing_raised do
      plugin.has_permission?(fast_create(Person), :make_ice_cream, fast_create(Environment))
    end
  end

  should 'display control panel button only to organizations with no parent' do
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)
    profile = fast_create(Profile)
    SubOrganizationsPlugin::Relation.add_children(org1,org2)
    context = mock()
    SubOrganizationsPlugin.any_instance.stubs(:context).returns(context)

    context.stubs(:profile).returns(org1)
    assert_not_nil plugin.control_panel_buttons

    context.stubs(:profile).returns(org2)
    assert_nil plugin.control_panel_buttons

    context.stubs(:profile).returns(profile)
    assert_nil plugin.control_panel_buttons
  end
end

