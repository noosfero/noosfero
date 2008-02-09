require File.dirname(__FILE__) + '/../test_helper'

class MembersBlockTest < Test::Unit::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, MembersBlock.new
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, MembersBlock.description
  end

  should 'link to "all members" page' do
    profile = create_user('mytestuser').person
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.save!

    expects(:_).with('All members').returns('All members')
    expects(:link_to).with('All members' , :profile => 'mytestuser', :controller => 'profile', :action => 'members').returns('link-to-members')

    assert_equal 'link-to-members', instance_eval(&block.footer)
  end

  should 'pick only members' do
    profile = create_user('mytestuser').person
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.save!

    assert_equal profile.members, block.profiles
  end

end
