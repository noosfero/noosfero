require File.dirname(__FILE__) + '/../test_helper'

class FavoriteEnterprisesBlockTest < ActiveSupport::TestCase
  
  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, FavoriteEnterprisesBlock.new
  end

  should 'declare its default title' do
    assert_not_equal ProfileListBlock.new.default_title, FavoriteEnterprisesBlock.new.default_title
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, FavoriteEnterprisesBlock.description
  end

  should 'use its own finder' do
    assert_not_equal FavoriteEnterprisesBlock::Finder, ProfileListBlock::Finder
    assert_kind_of FavoriteEnterprisesBlock::Finder, FavoriteEnterprisesBlock.new.profile_finder
  end

  should 'list owner favorite enterprises' do

    block = FavoriteEnterprisesBlock.new
    block.limit = 2

    owner = mock
    block.expects(:owner).returns(owner)

    member1 = mock; member1.stubs(:id).returns(1)
    member2 = mock; member2.stubs(:id).returns(2)
    member3 = mock; member3.stubs(:id).returns(3)

    owner.expects(:favorite_enterprises).returns([member1, member2, member3])
    
    block.profile_finder.expects(:pick_random).with(3).returns(2)
    block.profile_finder.expects(:pick_random).with(2).returns(0)

    Profile.expects(:find).with(3).returns(member3)
    Profile.expects(:find).with(1).returns(member1)

    assert_equal [member3, member1], block.profiles
  end

  should 'link to all enterprises for person' do
    person = Person.new
    person.expects(:identifier).returns('theprofile')
    block = FavoriteEnterprisesBlock.new
    block.expects(:owner).returns(person)

    expects(:__).with('View all').returns('View all enterprises')
    expects(:link_to).with('View all enterprises', :controller => 'profile', :profile => 'theprofile', :action => 'favorite_enterprises')

    instance_eval(&block.footer)
  end

  should 'give empty footer for unsupported owner type' do
    block = FavoriteEnterprisesBlock.new
    block.expects(:owner).returns(1)
    assert_equal '', block.footer
  end

  should 'count number of owner favorite enterprises' do
    user = create_user('testuser').person

    ent1 = fast_create(Enterprise, :name => 'test enterprise 1', :identifier => 'ent1')

    ent2 = fast_create(Enterprise, :name => 'test enterprise 2', :identifier => 'ent2')

    user.favorite_enterprises << [ent1, ent2]

    block = FavoriteEnterprisesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equal 2, block.profile_count
  end

end
