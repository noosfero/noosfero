require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase

  should 'inlude the parent field in organization' do
    organization = Organization.new
    assert_nothing_raised { organization.sub_organizations_plugin_parent_to_be = '999' }
  end

  should 'include the parent field in the FIELDS constant' do
    assert_includes Organization::FIELDS, 'sub_organizations_plugin_parent_to_be'
  end

  should 'relate organization with parent if the attribute is set' do
    parent = fast_create(Organization)
    organization = build(Organization, :identifier => 'some-org',:name => 'Some Org', :sub_organizations_plugin_parent_to_be => parent.id)
    assert_not_includes Organization.children(parent), organization

    organization.save!
    assert_includes Organization.children(parent), organization
  end

end
