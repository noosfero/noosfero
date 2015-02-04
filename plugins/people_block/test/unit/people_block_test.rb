require File.dirname(__FILE__) + '/../test_helper'

class PeopleBlockTest < ActionView::TestCase

  should 'inherit from Block' do
    assert_kind_of Block, PeopleBlock.new
  end


  should 'declare its default title' do
    assert_not_equal Block.new.default_title, PeopleBlock.new.default_title
  end


  should 'describe itself' do
    assert_not_equal Block.description, PeopleBlock.description
  end


  should 'is editable' do
    block = PeopleBlock.new
    assert block.editable?
  end


  should 'have field limit' do
    block = PeopleBlock.new
    assert_respond_to block, :limit
  end


  should 'default value of limit' do
    block = PeopleBlock.new
    assert_equal 6, block.limit
  end


  should 'have field name' do
    block = PeopleBlock.new
    assert_respond_to block, :name
  end


  should 'default value of name' do
    block = PeopleBlock.new
    assert_equal "", block.name
  end


  should 'have field address' do
    block = PeopleBlock.new
    assert_respond_to block, :address
  end


  should 'default value of address' do
    block = PeopleBlock.new
    assert_equal "", block.address
  end


  should 'prioritize profiles with image by default' do
    assert PeopleBlock.new.prioritize_profiles_with_image
  end


  should 'respect limit when listing people' do
    env = fast_create(Environment)
    p1 = fast_create(Person, :environment_id => env.id)
    p2 = fast_create(Person, :environment_id => env.id)
    p3 = fast_create(Person, :environment_id => env.id)
    p4 = fast_create(Person, :environment_id => env.id)

    block = PeopleBlock.new(:limit => 3)
    block.stubs(:owner).returns(env)

    assert_equal 3, block.profile_list.size
  end


  should 'accept a limit of people to be displayed' do
    block = PeopleBlock.new
    block.limit = 20
    assert_equal 20, block.limit
  end


  should 'list people from environment' do
    owner = fast_create(Environment)
    person1 = fast_create(Person, :environment_id => owner.id)
    person2 = fast_create(Person, :environment_id => owner.id)

    block = PeopleBlock.new

    block.expects(:owner).returns(owner).at_least_once
    expects(:profile_image_link).with(person1, :minor).returns(person1.name)
    expects(:profile_image_link).with(person2, :minor).returns(person2.name)
    expects(:block_title).with(anything).returns('')

    content = instance_exec(&block.content)

    assert_match(/#{person1.name}/, content)
    assert_match(/#{person2.name}/, content)
  end


  should 'link to "all people"' do
    env = fast_create(Environment)
    block = PeopleBlock.new

    instance_eval(&block.footer)
    assert_select 'a.view-all' do |elements|
      assert_select '[href=/search/people]'
    end
  end


  should 'count number of public and private people' do
    owner = fast_create(Environment)
    private_p = fast_create(Person, :public_profile => false, :environment_id => owner.id)
    public_p = fast_create(Person, :public_profile => true, :environment_id => owner.id)

    block = PeopleBlock.new
    block.expects(:owner).returns(owner).at_least_once

    assert_equal 2, block.profile_count
  end


  should 'not count number of invisible people' do
    owner = fast_create(Environment)
    private_p = fast_create(Person, :visible => false, :environment_id => owner.id)
    public_p = fast_create(Person, :visible => true, :environment_id => owner.id)

    block = PeopleBlock.new
    block.expects(:owner).returns(owner).at_least_once

    assert_equal 1, block.profile_count
  end

  protected
  include NoosferoTestHelper

end
