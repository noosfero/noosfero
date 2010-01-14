require File.dirname(__FILE__) + '/../test_helper'

class EnterprisesBlockTest < Test::Unit::TestCase

  include GetText

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, EnterprisesBlock.new
  end

  should 'declare its default title' do
    EnterprisesBlock.any_instance.stubs(:profile_count).returns(0)
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

    member1 = stub(:id => 1, :visible => true )
    member2 = stub(:id => 2, :visible => true )
    member3 = stub(:id => 3, :visible => true )

    owner.expects(:enterprises).returns([member1, member2, member3])
    
    block.profile_finder.expects(:pick_random).with(3).returns(2)
    block.profile_finder.expects(:pick_random).with(2).returns(0)

    Profile.expects(:find).with(3).returns(member3)
    Profile.expects(:find).with(1).returns(member1)

    assert_equal [member3, member1], block.profiles
  end

  should 'list private enterprises in environment' do
    env = Environment.create!(:name => 'test_env')
    enterprise1 = fast_create(Enterprise, :environment_id => env.id, :public_profile => true)
    enterprise2 = fast_create(Enterprise, :environment_id => env.id, :public_profile => false) #private profile
    block = EnterprisesBlock.new
    env.boxes.first.blocks << block
    block.save!
    ids = block.profile_finder.ids
    assert_includes ids, enterprise1.id
    assert_includes ids, enterprise2.id
  end

  should 'not list invisible enterprises in environment' do
    env = Environment.create!(:name => 'test_env')
    enterprise1 = fast_create(Enterprise, :environment_id => env.id, :visible => true)
    enterprise2 = fast_create(Enterprise, :environment_id => env.id, :visible => false) #invisible profile
    block = EnterprisesBlock.new
    env.boxes.first.blocks << block
    block.save!
    ids = block.profile_finder.ids
    assert_includes ids, enterprise1.id
    assert_not_includes ids, enterprise2.id
  end

  should 'list private enterprises in profile' do
    person = create_user('testuser').person
    enterprise1 = fast_create(Enterprise, :public_profile => true)
    role = Profile::Roles.member(enterprise1.environment.id)
    enterprise1.affiliate(person, role)
    enterprise2 = fast_create(Enterprise, :public_profile => false)
    enterprise2.affiliate(person, role)
    block = EnterprisesBlock.new
    person.boxes.first.blocks << block
    block.save!
    ids = block.profile_finder.ids
    assert_includes ids, enterprise1.id
    assert_includes ids, enterprise2.id
  end

  should 'not list invisible enterprises in profile' do
    person = create_user('testuser').person
    enterprise1 = fast_create(Enterprise, :visible => true)
    role = Profile::Roles.member(enterprise1.environment.id)
    enterprise1.affiliate(person, role)
    enterprise2 = fast_create(Enterprise, :visible => false)
    enterprise2.affiliate(person, role)
    block = EnterprisesBlock.new
    person.boxes.first.blocks << block
    block.save!
    ids = block.profile_finder.ids
    assert_includes ids, enterprise1.id
    assert_not_includes ids, enterprise2.id
  end

  should 'link to all enterprises for profile' do
    profile = Profile.new
    profile.expects(:identifier).returns('theprofile')
    block = EnterprisesBlock.new
    block.expects(:owner).returns(profile)

    expects(:link_to).with('View all', :controller => 'profile', :profile => 'theprofile', :action => 'enterprises')

    instance_eval(&block.footer)
  end

  should 'link to all enterprises for environment' do
    env = Environment.default
    block = EnterprisesBlock.new
    block.expects(:owner).returns(env)

    expects(:link_to).with('View all', :controller => 'search', :action => 'assets', :asset => 'enterprises')
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

  should 'count non-public person enterprises' do
    user = fast_create(Person)

    ent1 = fast_create(Enterprise, :public_profile => true)
    ent1.expects(:closed?).returns(false)
    ent1.add_member(user)

    ent2 = fast_create(Enterprise, :public_profile => false)
    ent2.expects(:closed?).returns(false)
    ent2.add_member(user)

    block = EnterprisesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equal 2, block.profile_count
  end

  should 'not count non-visible person enterprises' do
    user = fast_create(Person)

    ent1 = fast_create(Enterprise, :visible => true)
    ent1.expects(:closed?).returns(false)
    ent1.add_member(user)

    ent2 = fast_create(Enterprise, :visible => false)
    ent2.expects(:closed?).returns(false)
    ent2.add_member(user)

    block = EnterprisesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equal 1, block.profile_count
  end


  should 'count non-public environment enterprises' do
    env = fast_create(Environment)
    ent1 = fast_create(Enterprise, :environment_id => env.id, :public_profile => true)
    ent2 = fast_create(Enterprise, :environment_id => env.id, :public_profile => false)

    block = EnterprisesBlock.new
    block.expects(:owner).at_least_once.returns(env)

    assert_equal 2, block.profile_count
  end

  should 'not count non-visible environment enterprises' do
    env = Environment.create!(:name => 'test_env')
    ent1 = Enterprise.create!(:name => 'test enterprise 1', :identifier => 'ent1', :environment => env, :visible => true)
    ent2 = Enterprise.create!(:name => 'test enterprise 2', :identifier => 'ent2', :environment => env, :visible => false)

    block = EnterprisesBlock.new
    block.expects(:owner).at_least_once.returns(env)

    assert_equal 1, block.profile_count
  end

end
