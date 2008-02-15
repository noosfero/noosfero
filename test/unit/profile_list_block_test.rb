require File.dirname(__FILE__) + '/../test_helper'

class ProfileListBlockTest < Test::Unit::TestCase

  should 'describe itself' do
    assert_not_equal Block.description, ProfileListBlock.description
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

    owner = create_user('mytestuser').person
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

  should 'pick most recently-added profiles by default' do
    Profile.expects(:find).with(:all, { :limit => 10, :order => 'created_at desc'})

    block = ProfileListBlock.new
    block.limit = 10
    block.profiles
  end

  should 'use finders to find profiles to be listed' do
    block = ProfileListBlock.new
    finder = mock
    block.expects(:profile_finder).returns(finder).once
    finder.expects(:find)
    block.profiles
  end


end
