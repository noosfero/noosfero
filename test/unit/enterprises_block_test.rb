require File.dirname(__FILE__) + '/../test_helper'

class EnterprisesBlockTest < Test::Unit::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, EnterprisesBlock.new
  end

  should 'declare its default title' do
    assert_not_equal ProfileListBlock.new.default_title, EnterprisesBlock.new.default_title
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, EnterprisesBlock.description
  end

  should 'use its own finder' do
    assert_not_equal EnterprisesBlock::Finder, ProfileListBlock::Finder
    assert_kind_of EnterprisesBlock::Finder, EnterprisesBlock.new.profile_finder
  end

  should 'list owner enterprises' do
    block = EnterprisesBlock.new
    block.limit = 2

    owner = mock
    block.expects(:owner).at_least_once.returns(owner)

    member1 = stub(:id => 1, :public_profile => true )
    member2 = stub(:id => 2, :public_profile => true )
    member3 = stub(:id => 3, :public_profile => true )

    owner.expects(:enterprises).returns([member1, member2, member3])
    
    block.profile_finder.expects(:pick_random).with(3).returns(2)
    block.profile_finder.expects(:pick_random).with(2).returns(0)

    Profile.expects(:find).with(3).returns(member3)
    Profile.expects(:find).with(1).returns(member1)

    assert_equal [member3, member1], block.profiles
  end

  should 'not list private enterprises in environment' do
    env = Environment.create!(:name => 'test env')
    p1 = Enterprise.create!(:name => 'test1', :identifier => 'test1', :environment_id => env.id, :public_profile => true)
    p2 = Enterprise.create!(:name => 'test2', :identifier => 'test2', :environment_id => env.id, :public_profile => false) #private profile
    block = EnterprisesBlock.new
    env.boxes.first.blocks << block
    block.save!
    ids = block.profile_finder.ids
    assert_includes ids, p1.id
    assert_not_includes ids, p2.id
  end

  should 'not list private enterprises in profile' do
    person = create_user('test_user').person
    role = Profile::Roles.member
    e1 = Enterprise.create!(:name => 'test1', :identifier => 'test1', :public_profile => true)
    e1.affiliate(person, role)
    e2 = Enterprise.create!(:name => 'test2', :identifier => 'test2', :public_profile => false) #private profile
    e2.affiliate(person, role)
    block = EnterprisesBlock.new
    person.boxes.first.blocks << block
    block.save!
    ids = block.profile_finder.ids
    assert_includes ids, e1.id
    assert_not_includes ids, e2.id
  end

  should 'link to all enterprises for profile' do
    profile = Profile.new
    profile.expects(:identifier).returns('theprofile')
    block = EnterprisesBlock.new
    block.expects(:owner).returns(profile)

    expects(:__).with('View all').returns('All enterprises')
    expects(:link_to).with('All enterprises', :controller => 'profile', :profile => 'theprofile', :action => 'enterprises')

    instance_eval(&block.footer)
  end

  should 'link to all enterprises for environment' do
    env = Environment.default
    block = EnterprisesBlock.new
    block.expects(:owner).returns(env)

    expects(:__).with('View all').returns('All enterprises')
    expects(:link_to).with('All enterprises', :controller => 'search', :action => 'assets', :asset => 'enterprises')
    instance_eval(&block.footer)
  end

  should 'give empty footer for unsupported owner type' do
    block = EnterprisesBlock.new
    block.expects(:owner).returns(1)
    assert_equal '', block.footer
  end

  should 'count number of owner enterprises' do
    user = create_user('testuser').person

    ent1 = Enterprise.create!(:name => 'test enterprise 1', :identifier => 'ent1', :environment => Environment.default)
    ent1.expects(:closed?).returns(false)
    ent1.add_member(user)

    ent2 = Enterprise.create!(:name => 'test enterprise 2', :identifier => 'ent2', :environment => Environment.default)
    ent2.expects(:closed?).returns(false)
    ent2.add_member(user)

    block = EnterprisesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equal 2, block.profile_count
  end

end
