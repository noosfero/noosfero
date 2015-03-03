require_relative '../test_helper'

class FriendsBlockTest < ActionView::TestCase

  should 'inherit from Block' do
    assert_kind_of Block, FriendsBlock.new
  end

  should 'declare its default title' do
    FriendsBlock.any_instance.expects(:profile_count).returns(0)
    assert_not_equal Block.new.default_title, FriendsBlock.new.default_title
  end

  should 'describe itself' do
    assert_not_equal Block.description, FriendsBlock.description
  end

  should 'is editable' do
    block = FriendsBlock.new
    assert block.editable?
  end

  should 'have field limit' do
    block = FriendsBlock.new
    assert_respond_to block, :limit
  end

  should 'default value of limit' do
    block = FriendsBlock.new
    assert_equal 6, block.limit
  end

  should 'have field name' do
    block = FriendsBlock.new
    assert_respond_to block, :name
  end

  should 'default value of name' do
    block = FriendsBlock.new
    assert_equal "", block.name
  end

  should 'have field address' do
    block = FriendsBlock.new
    assert_respond_to block, :address
  end

  should 'default value of address' do
    block = FriendsBlock.new
    assert_equal "", block.address
  end

  should 'prioritize profiles with image by default' do
    assert FriendsBlock.new.prioritize_profiles_with_image
  end

  should 'accept a limit of people to be displayed' do
    block = FriendsBlock.new
    block.limit = 20
    assert_equal 20, block.limit
  end

  should 'list friends from person' do
    owner = fast_create(Person)
    friend1 = fast_create(Person)
    friend2 = fast_create(Person)
    owner.add_friend(friend1)
    owner.add_friend(friend2)

    block = FriendsBlock.new

    block.expects(:owner).returns(owner).at_least_once
    expects(:profile_image_link).with(friend1, :minor).returns(friend1.name)
    expects(:profile_image_link).with(friend2, :minor).returns(friend2.name)
    expects(:block_title).with(anything).returns('')

    content = instance_eval(&block.content)

    assert_match(/#{friend1.name}/, content)
    assert_match(/#{friend2.name}/, content)
  end

  should 'link to "all friends"' do
    person1 = create_user('mytestperson').person

    block = FriendsBlock.new
    block.stubs(:suggestions).returns([])
    block.expects(:owner).returns(person1).at_least_once

    instance_eval(&block.footer)
    assert_select 'a.view-all' do |elements|
      assert_select '[href=/profile/mytestperson/friends]'
    end
  end

  should 'count number of owner friends' do
    owner = fast_create(Person)
    friend1 = fast_create(Person)
    friend2 = fast_create(Person)
    friend3 = fast_create(Person)
    owner.add_friend(friend1)
    owner.add_friend(friend2)
    owner.add_friend(friend3)

    block = FriendsBlock.new
    block.expects(:owner).returns(owner).at_least_once

    assert_equal 3, block.profile_count
  end

  should 'count number of public and private friends' do
    owner = fast_create(Person)
    private_p = fast_create(Person, {:public_profile => false})
    public_p = fast_create(Person, {:public_profile => true})

    owner.add_friend(private_p)
    owner.add_friend(public_p)

    block = FriendsBlock.new
    block.expects(:owner).returns(owner).at_least_once

    assert_equal 2, block.profile_count
  end

  should 'not count number of invisible friends' do
    owner = fast_create(Person)
    private_p = fast_create(Person, {:visible => false})
    public_p = fast_create(Person, {:visible => true})

    owner.add_friend(private_p)
    owner.add_friend(public_p)

    block = FriendsBlock.new
    block.expects(:owner).returns(owner).at_least_once

    assert_equal 1, block.profile_count
  end

  should 'list owner\'s friends suggestions' do
    owner = fast_create(Person)
    suggestion1 = owner.profile_suggestions.create(:suggestion => fast_create(Person))
    suggestion2 = owner.profile_suggestions.create(:suggestion => fast_create(Person))

    block = FriendsBlock.new
    block.stubs(:owner).returns(owner)

    assert_equivalent block.suggestions, [suggestion1,suggestion2]
  end

  protected
  include NoosferoTestHelper

end
