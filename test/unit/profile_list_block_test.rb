require File.dirname(__FILE__) + '/../test_helper'

class ProfileListBlockTest < Test::Unit::TestCase

  should 'describe itself' do
    assert_not_equal Block.description, ProfileListBlock.description
  end

  should 'provide a default title' do
    assert_not_equal Block.new.default_title, ProfileListBlock.new.default_title
  end

  should 'accept a limit of people to be displayed (and default to 6)' do
    block = ProfileListBlock.new
    assert_equal 6, block.limit

    block.limit = 20
    assert_equal 20, block.limit
  end

  should 'list people' do
    User.destroy_all
    person1 = create_user('testperson1').person
    person2 = create_user('testperson2').person
    person3 = create_user('testperson3').person

    owner = Environment.create!(:name => 'test env')
    block = ProfileListBlock.new
    owner.boxes.first.blocks << block
    block.save!

    profiles = [person1, person3]
    block.expects(:profiles).returns(profiles)

    self.expects(:profile_image_link).with(person1).once
    self.expects(:profile_image_link).with(person2).never
    self.expects(:profile_image_link).with(person3).once

    self.expects(:content_tag).returns('<div></div>').at_least_once
    self.expects(:block_title).returns('block title').at_least_once

    assert_kind_of String, instance_eval(&block.content)
  end

  should 'list private profiles' do
    env = Environment.create!(:name => 'test env')
    profile1 = fast_create(Profile, :environment_id => env.id)
    profile2 = fast_create(Profile, :environment_id => env.id, :public_profile => false) # private profile
    block = ProfileListBlock.new
    env.boxes.first.blocks << block
    block.save!

    ids = block.profile_finder.ids
    assert_includes ids, profile1.id
    assert_includes ids, profile2.id
  end

  should 'not list invisible profiles' do
    env = Environment.create!(:name => 'test env')
    profile1 = fast_create(Profile, :environment_id => env.id)
    profile2 = fast_create(Profile, :environment_id => env.id, :visible => false) # not visible profile
    block = ProfileListBlock.new
    env.boxes.first.blocks << block
    block.save!

    ids = block.profile_finder.ids
    assert_includes ids, profile1.id
    assert_not_includes ids, profile2.id
  end

  should 'use finders to find profiles to be listed' do
    block = ProfileListBlock.new
    finder = mock
    block.expects(:profile_finder).returns(finder).once
    finder.expects(:find)
    block.profiles
  end

  should 'provide random numbers' do
    assert_respond_to ProfileListBlock::Finder.new(nil), :pick_random
  end

  should 'provide view_title' do
    env = Environment.create!(:name => 'test env')
    block = ProfileListBlock.new(:title => 'Title from block')
    env.boxes.first.blocks << block
    block.save!
    assert_equal 'Title from block', block.view_title
  end
  
  should 'provide view title with variables' do
    env = Environment.create!(:name => 'test env')
    block = ProfileListBlock.new(:title => '{#} members')
    env.boxes.first.blocks << block
    block.save!
    assert_equal '0 members', block.view_title
  end

  should 'count number of public and private profiles' do
    env = Environment.create!(:name => 'test env')
    block = ProfileListBlock.new
    env.boxes.first.blocks << block
    block.save!

    priv_p = fast_create(Person, :environment_id => env.id, :public_profile => false)
    pub_p = fast_create(Person, :environment_id => env.id, :public_profile => true)

    priv_c = fast_create(Community, :public_profile => false, :environment_id => env.id)
    pub_c = fast_create(Community, :public_profile => true , :environment_id => env.id)

    priv_e = fast_create(Enterprise, :public_profile => false , :environment_id => env.id)
    pub_e = fast_create(Enterprise, :public_profile => true , :environment_id => env.id)

    assert_equal 6, block.profile_count
  end

  should 'only count number of visible profiles' do
    env = Environment.create!(:name => 'test env')
    block = ProfileListBlock.new
    env.boxes.first.blocks << block
    block.save!

    priv_p = fast_create(Person, :environment_id => env.id, :visible => false)
    pub_p = fast_create(Person, :environment_id => env.id, :visible => true)

    priv_c = fast_create(Community, :visible => false, :environment_id => env.id)
    pub_c = fast_create(Community, :visible => true , :environment_id => env.id)

    priv_e = fast_create(Enterprise, :visible => false , :environment_id => env.id)
    pub_e = fast_create(Enterprise, :visible => true , :environment_id => env.id)

    assert_equal 3, block.profile_count
  end

end
