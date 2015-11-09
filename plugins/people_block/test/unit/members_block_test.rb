require_relative '../test_helper'

class MembersBlockTest < ActionView::TestCase

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
    assert MembersBlock.new.prioritize_profiles_with_image
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

  should 'provide link to members page without a visible_role selected' do
    profile = create_user('mytestuser').person
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.save!

    instance_eval(&block.footer)
    assert_select 'a.view-all' do |elements|
      assert_select "[href=/profile/mytestuser/members#members-tab]"
    end
  end

  should 'provide link to members page when visible_role is profile_member' do
    profile = create_user('mytestuser').person
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.visible_role = 'profile_member'
    block.save!

    instance_eval(&block.footer)
    assert_select 'a.view-all' do |elements|
      assert_select '[href=/profile/mytestuser/members#members-tab]'
    end
  end

  should 'provide link to members page when visible_role is profile_moderator' do
    profile = create_user('mytestuser').person
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.visible_role = 'profile_moderator'
    block.save!

    instance_eval(&block.footer)
    assert_select 'a.view-all' do |elements|
      assert_select '[href=/profile/mytestuser/members#members-tab]'
    end
  end

  should 'provide link to admins page when visible_role is profile_admin' do
    profile = create_user('mytestuser').person
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.visible_role = 'profile_admin'
    block.save!

    instance_eval(&block.footer)
    assert_select 'a.view-all' do |elements|
      assert_select '[href=/profile/mytestuser/members#admins-tab]'
    end
  end

  should 'provide a role to be displayed (and default to nil)' do
    env = fast_create(Environment)
    env.boxes << Box.new
    block = MembersBlock.new
    assert_equal nil, block.visible_role
    env.boxes.first.blocks << block
    block.visible_role = 'profile_member'
    block.save!
    assert_equal 'profile_member', block.visible_role
  end

  should 'list all members' do
    env = fast_create(Environment)
    env.boxes << Box.new
    profile1 = fast_create(Person, :environment_id => env.id)
    profile2 = fast_create(Person, :environment_id => env.id)

    block = MembersBlock.new
    owner = fast_create(Community)
    block.stubs(:owner).returns(owner)
    env.boxes.first.blocks << block
    block.save!

    owner.add_member profile1
    owner.add_member profile2
    profiles = block.profiles

    assert_includes profiles, profile1
    assert_includes profiles, profile2
  end

  should 'list only profiles with moderator role' do
    env = fast_create(Environment)
    env.boxes << Box.new
    profile1 = fast_create(Person, :environment_id => env.id)
    profile2 = fast_create(Person, :environment_id => env.id)

    block = MembersBlock.new
    owner = fast_create(Community)
    block.visible_role = Profile::Roles.moderator(owner.environment.id).key
    block.stubs(:owner).returns(owner)
    env.boxes.first.blocks << block
    block.save!

    owner.add_member profile2
    owner.add_moderator profile1
    profiles = block.profiles

    assert_includes profiles, profile1
    assert_not_includes profiles, profile2
  end

  should 'list only profiles with member role' do
    env = fast_create(Environment)
    env.boxes << Box.new
    profile1 = fast_create(Person, :environment_id => env.id)
    profile2 = fast_create(Person, :environment_id => env.id)

    block = MembersBlock.new
    owner = fast_create(Community)
    block.visible_role = Profile::Roles.member(owner.environment.id).key
    block.stubs(:owner).returns(owner)
    env.boxes.first.blocks << block
    block.save!

    owner.add_member profile2
    owner.add_moderator profile1
    profiles = block.profiles

    assert_not_includes profiles, profile1
    assert_includes profiles, profile2
  end

  should 'list available roles' do
    block = MembersBlock.new
    owner = fast_create(Community)
    block.stubs(:owner).returns(owner)
    assert_includes block.roles, Profile::Roles.member(owner.environment.id)
    assert_includes block.roles, Profile::Roles.admin(owner.environment.id)
    assert_includes block.roles, Profile::Roles.moderator(owner.environment.id)
  end

  protected
  include NoosferoTestHelper

end
