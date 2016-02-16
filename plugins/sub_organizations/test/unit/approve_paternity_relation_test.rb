require 'test_helper'

class ApprovePaternityRelationTest < ActiveSupport::TestCase

  def setup
    @requestor = create_user('some-user').person
  end

  attr_reader :requestor

  should 'return parent' do
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)
    task = SubOrganizationsPlugin::ApprovePaternity.create!(:requestor => requestor, :target => org2, :temp_parent_id => org1.id, :temp_parent_type => org1.class.name)

    assert_equal SubOrganizationsPlugin::ApprovePaternityRelation.parent_approval(task), org1
  end

  should 'list pending children' do
    organization = fast_create(Organization)
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)
    org3 = fast_create(Organization)

    SubOrganizationsPlugin::ApprovePaternity.create!(:requestor => requestor, :target => org1, :temp_parent_id => organization.id, :temp_parent_type => organization.class.name)
    SubOrganizationsPlugin::ApprovePaternity.create!(:requestor => requestor, :target => org2, :temp_parent_id => organization.id, :temp_parent_type => organization.class.name)

    assert_includes Organization.pending_children(organization), org1
    assert_includes Organization.pending_children(organization), org2
    assert_not_includes Organization.pending_children(organization), org3
  end
end
