require 'test_helper'

class SubOrganizationsPlugin::RelationTest < ActiveSupport::TestCase

  should 'validates presence of child and parent' do
    org = fast_create(Organization)
    relation = SubOrganizationsPlugin::Relation.new

    relation.parent = org
    relation.valid?
    assert relation.errors.include?(:child)

    relation.parent = nil
    relation.child = org
    relation.valid?
    assert relation.errors.include?(:parent)
  end

  should 'relate two organizations' do
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)
    relation = SubOrganizationsPlugin::Relation.create!(:parent => org1, :child => org2)

    assert_equal org1, relation.parent
    assert_equal org2, relation.child
  end

  should 'not allow self relation' do
    org = fast_create(Organization)
    relation = SubOrganizationsPlugin::Relation.new(:parent => org, :child => org)
    assert !relation.valid?
    assert relation.errors.include?(:child)
  end

  should 'be able to retrieve parents of an organization' do
    child = fast_create(Organization)
    parent1 = fast_create(Organization)
    parent2 = fast_create(Organization)
    SubOrganizationsPlugin::Relation.create!(:parent => parent1, :child => child)
    SubOrganizationsPlugin::Relation.create!(:parent => parent2, :child => child)

    assert_includes Organization.parents(child), parent1
    assert_includes Organization.parents(child), parent2
  end

  should 'be able to retrieve children of an organization' do
    parent = fast_create(Organization)
    child1 = fast_create(Organization)
    child2 = fast_create(Organization)
    SubOrganizationsPlugin::Relation.create!(:parent => parent, :child => child1)
    SubOrganizationsPlugin::Relation.create!(:parent => parent, :child => child2)

    assert_includes Organization.children(parent), child1
    assert_includes Organization.children(parent), child2
  end

  should 'not allow cyclical reference' do
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)
    SubOrganizationsPlugin::Relation.create!(:parent => org1, :child => org2)
    relation = SubOrganizationsPlugin::Relation.new(:parent => org2, :child => org1)

    assert !relation.valid?
    assert relation.errors.include?(:child)
  end

  should 'not allow multi-level paternity' do
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)
    org3 = fast_create(Organization)
    SubOrganizationsPlugin::Relation.create!(:parent => org1, :child => org2)
    r1 = SubOrganizationsPlugin::Relation.new(:parent => org2, :child => org3)
    r2 = SubOrganizationsPlugin::Relation.new(:parent => org3, :child => org1)

    assert !r1.valid?
    assert r1.errors.include?(:child)

    assert !r2.valid?
    assert r2.errors.include?(:child)
  end

  should 'add children' do
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)
    org3 = fast_create(Organization)
    org4 = fast_create(Organization)

    SubOrganizationsPlugin::Relation.add_children(org1,org2)
    assert_includes Organization.children(org1), org2

    SubOrganizationsPlugin::Relation.add_children(org1,org3,org4)
    assert_includes Organization.children(org1), org3
    assert_includes Organization.children(org1), org4
  end

  should 'remove children' do
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)
    org3 = fast_create(Organization)
    org4 = fast_create(Organization)
    SubOrganizationsPlugin::Relation.add_children(org1,org2,org3,org4)

    SubOrganizationsPlugin::Relation.remove_children(org1,org2)
    assert_not_includes Organization.children(org1), org2

    SubOrganizationsPlugin::Relation.remove_children(org1,org3,org4)
    assert_not_includes Organization.children(org1), org3
    assert_not_includes Organization.children(org1), org4
  end
end
