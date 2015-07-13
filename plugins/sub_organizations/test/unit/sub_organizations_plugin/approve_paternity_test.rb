require 'test_helper'

class SubOrganizationsPlugin::ApprovePaternityTest < ActiveSupport::TestCase

  def setup
    @requestor = create_user('some-user').person
  end

  attr_reader :requestor

  should 'create relation after creation' do
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)
    assert_difference 'SubOrganizationsPlugin::ApprovePaternityRelation.count', 1 do
      SubOrganizationsPlugin::ApprovePaternity.create!(:requestor => requestor, :temp_parent_id => org1.id, :temp_parent_type => org1.class.name, :target => org2)
    end
  end

  should 'add children to parent after approving' do
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)

    task = SubOrganizationsPlugin::ApprovePaternity.create!(:requestor => requestor, :temp_parent_id => org1.id, :temp_parent_type => org1.class.name, :target => org2)
    assert_not_includes Organization.children(org1), org2

    task.finish
    assert_includes Organization.children(org1), org2
  end
end
