require_relative "../test_helper"

class ScopeToolTest < ActiveSupport::TestCase
  include ScopeTool

  should 'unite scopes' do
    cmm = fast_create Community
    ent = fast_create Enterprise
    orgs = union(Profile.communities, Profile.enterprises)
    assert orgs.include? cmm
    assert orgs.include? ent
  end

  should 'filter united scopes' do
    cmm1 = fast_create Community, :visible => true
    cmm2 = fast_create Community, :visible => false
    ent1 = fast_create Enterprise, :visible => true
    ent2 = fast_create Enterprise, :visible => false
    orgs = union(Profile.communities, Profile.enterprises)
    assert orgs.include? cmm1
    assert orgs.include? cmm2
    assert orgs.include? ent1
    assert orgs.include? ent2
    orgs = orgs.visible
    assert orgs.include? cmm1
    refute orgs.include?(cmm2)
    assert orgs.include? ent1
    refute orgs.include?(ent2)
  end

end
