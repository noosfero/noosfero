require File.dirname(__FILE__) + '/../test_helper'

class MembersBlockTest < Test::Unit::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, MembersBlock.new
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, MembersBlock.description
  end

  should 'provide a default title' do
    assert_not_equal ProfileListBlock.new.default_title, MembersBlock.new.default_title
  end

  should 'link to "all members" page' do
    profile = create_user('mytestuser').person
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.save!

    expects(:_).with('View all').returns('View all')
    expects(:link_to).with('View all' , :profile => 'mytestuser', :controller => 'profile', :action => 'members').returns('link-to-members')

    assert_equal 'link-to-members', instance_eval(&block.footer)
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

