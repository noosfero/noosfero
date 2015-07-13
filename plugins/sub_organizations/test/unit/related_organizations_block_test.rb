require 'test_helper'
require_relative '../../lib/related_organizations_block'

class RelatedOrganizationsBlockTest < ActiveSupport::TestCase

  def setup
    @block = RelatedOrganizationsBlock.new
  end

  attr_reader :block

  should 'have both as default organization_type' do
    assert_equal "both", block.organization_type
  end

  should 'return only children when the organization is a parent' do
    parent = fast_create(Organization, :name => 'I am your father', :identifier => 'i-am-your-father')
    child1 = fast_create(Organization, :name => 'Rebel Alliance')
    child2 = fast_create(Organization, :name => 'The Empire')
    org1 = fast_create(Organization, :name => 'Jedi Council')
    box = fast_create(Box, :owner_id => parent.id, :owner_type => 'Organization')
    @block.box = box
    @block.save!
    SubOrganizationsPlugin::Relation.add_children(parent, child1, child2)

    assert @block.related_organizations.include?(child1)
    assert @block.related_organizations.include?(child2)
    assert !@block.related_organizations.include?(org1)
  end
end
