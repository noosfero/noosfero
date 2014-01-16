require File.dirname(__FILE__) + '/../test_helper'

class MembersBlockTest < ActiveSupport::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, MembersBlock.new
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, MembersBlock.description
  end

  should 'provide a default title' do
    assert_not_equal ProfileListBlock.new.default_title, MembersBlock.new.default_title
  end

  should 'display members file' do
    community = fast_create(Community)
    block = MembersBlock.create
    block.expects(:owner).returns(community)

    self.expects(:render).with(:file => 'blocks/members', :locals => { :profile => community, :show_join_leave_button => false}).returns('file-with-members-list')
    assert_equal 'file-with-members-list', instance_eval(&block.footer)
  end

  should 'pick random members' do
    block = MembersBlock.new

    owner = mock
    block.expects(:owner).returns(owner)

    list = []
    owner.expects(:members).returns(list)
    
    assert_same list, block.profiles
  end

end
