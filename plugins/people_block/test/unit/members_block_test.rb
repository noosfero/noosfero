require File.dirname(__FILE__) + '/../test_helper'

class MembersBlockTest < ActiveSupport::TestCase

  should 'inherit from Block' do
    assert_kind_of Block, MembersBlock.new
  end


  should 'declare its default title' do
    assert_not_equal Block.new.default_title, MembersBlock.new.default_title
  end


  should 'describe itself' do
    assert_not_equal Block.description, MembersBlock.description
  end


  should 'is editable' do
    block = MembersBlock.new
    assert block.editable?
  end


  should 'have field limit' do
    block = MembersBlock.new
    assert_respond_to block, :limit
  end


  should 'default value of limit' do
    block = MembersBlock.new
    assert_equal 6, block.limit
  end


  should 'have field name' do
    block = MembersBlock.new
    assert_respond_to block, :name
  end


  should 'default value of name' do
    block = MembersBlock.new
    assert_equal "", block.name
  end


  should 'have field address' do
    block = MembersBlock.new
    assert_respond_to block, :address
  end


  should 'default value of address' do
    block = MembersBlock.new
    assert_equal "", block.address
  end


  should 'prioritize profiles with image by default' do
    assert MembersBlock.new.prioritize_people_with_image
  end


  should 'respect limit when listing members' do
    community = fast_create(Community)
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    p4 = fast_create(Person)

    community.add_member(p1)
    community.add_member(p2)
    community.add_member(p3)
    community.add_member(p4)

    block = MembersBlock.new(:limit => 3)
    block.stubs(:owner).returns(community)

    assert_equal 3, block.profile_list.size
  end


  should 'accept a limit of members to be displayed' do
    block = MembersBlock.new
    block.limit = 20
    assert_equal 20, block.limit
  end


  should 'list members from community' do
    owner = fast_create(Community)
    person1 = fast_create(Person)
    person2 = fast_create(Person)
    owner.add_member(person1)
    owner.add_member(person2)

    block = MembersBlock.new

    block.expects(:owner).returns(owner).at_least_once
    expects(:profile_image_link).with(person1, :minor).returns(person1.name)
    expects(:profile_image_link).with(person2, :minor).returns(person2.name)
    expects(:block_title).with(anything).returns('')

    content = instance_eval(&block.content)

    assert_match(/#{person1.name}/, content)
    assert_match(/#{person2.name}/, content)
  end


  should 'link to "all members"' do
    community = fast_create(Community)

    block = MembersBlock.new
    block.expects(:owner).returns(community).at_least_once

    expects(:_).with('View all').returns('View all')
    expects(:link_to).with('View all', :profile => community.identifier, :controller => 'profile', :action => 'members').returns('link-to-members')

    assert_equal 'link-to-members', instance_eval(&block.footer)
  end


  should 'count number of public and private members' do
    owner = fast_create(Community)
    private_p = fast_create(Person, {:public_profile => false})
    public_p = fast_create(Person, {:public_profile => true})

    owner.add_member(private_p)
    owner.add_member(public_p)

    block = MembersBlock.new
    block.expects(:owner).returns(owner).at_least_once

    assert_equal 2, block.profile_count
  end


  should 'not count number of invisible members' do
    owner = fast_create(Community)
    private_p = fast_create(Person, {:visible => false})
    public_p = fast_create(Person, {:visible => true})

    owner.add_member(private_p)
    owner.add_member(public_p)

    block = MembersBlock.new
    block.expects(:owner).returns(owner).at_least_once

    assert_equal 1, block.profile_count
  end

  protected
  include NoosferoTestHelper

end
