require_relative "../test_helper"

class MembersBlockTest < ActionView::TestCase
  should "inherit from Block" do
    assert_kind_of Block, MembersBlock.new
  end

  should "declare its default title" do
    assert_not_equal Block.new.default_title, MembersBlock.new.default_title
  end

  should "describe itself" do
    assert_not_equal Block.description, MembersBlock.description
  end

  should "is editable" do
    block = MembersBlock.new
    assert block.editable?
  end

  should "have field limit" do
    block = MembersBlock.new
    assert_respond_to block, :limit
  end

  should "default value of limit" do
    block = MembersBlock.new
    assert_equal 6, block.limit
  end

  should "have field name" do
    block = MembersBlock.new
    assert_respond_to block, :name
  end

  should "default value of name" do
    block = MembersBlock.new
    assert_equal "", block.name
  end

  should "have field address" do
    block = MembersBlock.new
    assert_respond_to block, :address
  end

  should "default value of address" do
    block = MembersBlock.new
    assert_equal "", block.address
  end

  should "prioritize profiles with image by default" do
    assert MembersBlock.new.prioritize_profiles_with_image
  end

  should "respect limit when listing members" do
    community = fast_create(Community)
    u1 = create_user
    u1.activate!
    p1 = u1.person

    u2 = create_user
    u2.activate!
    p2 = u2.person

    u3 = create_user
    u3.activate!
    p3 = u3.person

    u4 = create_user
    u4.activate!
    p4 = u4.person

    community.add_member(p1)
    community.add_member(p2)
    community.add_member(p3)
    community.add_member(p4)

    block = MembersBlock.new(limit: 3)
    block.stubs(:owner).returns(community)

    assert_equal 3, block.profile_list.size
  end

  should "accept a limit of members to be displayed" do
    block = MembersBlock.new
    block.limit = 20
    assert_equal 20, block.limit
  end

  should "count number of public and private members" do
    owner = fast_create(Community)
    private_p = fast_create(Person, access: Entitlement::Levels.levels[:self])
    public_p = fast_create(Person)

    owner.add_member(private_p)
    owner.add_member(public_p)

    block = MembersBlock.new
    block.expects(:owner).returns(owner).at_least_once

    assert_equal 1, block.profile_count
    assert_equal 2, block.profile_count(private_p)
  end

  should "not count number of invisible members" do
    owner = fast_create(Community)
    private_p = fast_create(Person, visible: false)
    public_p = fast_create(Person, visible: true)

    owner.add_member(private_p)
    owner.add_member(public_p)

    block = MembersBlock.new
    block.expects(:owner).returns(owner).at_least_once

    assert_equal 1, block.profile_count
  end

  should "provide a role to be displayed (and default to nil)" do
    env = fast_create(Environment)
    env.boxes << Box.new
    block = MembersBlock.new
    assert_nil block.visible_role
    env.boxes.first.blocks << block
    block.visible_role = "profile_member"
    block.save!
    assert_equal "profile_member", block.visible_role
  end

  should "list all members" do
    env = fast_create(Environment)
    env.boxes << Box.new
    profile1 = fast_create(Person, environment_id: env.id)
    profile2 = fast_create(Person, environment_id: env.id)

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

  should "list only profiles with moderator role" do
    env = fast_create(Environment)
    env.boxes << Box.new
    u1 = create_user
    u1.activate!
    profile1 = u1.person

    u2 = create_user
    u2.activate!
    profile2 = u2.person

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

    profile_list = block.profile_list
    assert_includes profile_list, profile1
    assert_not_includes profile_list, profile2
  end

  should "list only profiles with member role" do
    env = fast_create(Environment)
    env.boxes << Box.new
    u1 = create_user
    u1.activate!
    profile1 = u1.person

    u2 = create_user
    u2.activate!
    profile2 = u2.person

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

    profile_list = block.profile_list
    assert_not_includes profile_list, profile1
    assert_includes profile_list, profile2
  end

  should "list available roles" do
    block = MembersBlock.new
    owner = fast_create(Community)
    block.stubs(:owner).returns(owner)
    assert_includes block.roles, Profile::Roles.member(owner.environment.id)
    assert_includes block.roles, Profile::Roles.admin(owner.environment.id)
    assert_includes block.roles, Profile::Roles.moderator(owner.environment.id)
  end

  should "count number of profiles by role" do
    owner = fast_create(Community)
    u1 = create_user(nil)
    u1.activate!
    profile1 = u1.person

    u2 = create_user(nil)
    u2.activate!
    profile2 = u2.person

    owner.add_member profile2
    owner.add_moderator profile1

    block = MembersBlock.new
    block.visible_role = Profile::Roles.moderator(owner.environment.id).key
    block.expects(:owner).returns(owner).at_least_once

    assert_equivalent [profile1], block.profile_list
  end

  protected

    include NoosferoTestHelper
end

require "boxes_helper"

class MembersBlockViewTest < ActionView::TestCase
  include BoxesHelper

  def setup
    view.stubs(:user).returns(nil)
  end

  should "list members from community" do
    owner = fast_create(Community)
    user1 = create_user
    user1.activate!
    person1 = user1.person
    user2 = create_user
    user2.activate!
    person2 = user2.person
    owner.add_member(person1)
    owner.add_member(person2)
    profile = Profile.new
    profile.identifier = 42

    block = MembersBlock.new

    block.expects(:owner).returns(owner).at_least_once
    ActionView::Base.any_instance.expects(:profile_image_link).with(person1, :minor).returns(person1.name)
    ActionView::Base.any_instance.expects(:profile_image_link).with(person2, :minor).returns(person2.name)
    ActionView::Base.any_instance.expects(:block_title).with(anything, anything).returns("")
    ActionView::Base.any_instance.stubs(:theme_option).returns(nil)

    content = render_block_content(block)

    assert_match(/#{person1.name}/, content)
    assert_match(/#{person2.name}/, content)
  end

  should "provide link to members page without a visible_role selected" do
    env = fast_create(Environment)
    profile = fast_create(Community, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    member = fast_create(Person, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    relation = RoleAssignment.new(resource_id: profile.id, resource_type: "Profile", role_id: 3)
    relation.accessor = member
    relation.save
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.expects(:owner).returns(profile.reload).at_least_once
    block.save!

    ActionView::Base.any_instance.stubs(:block_title).returns("")
    ActionView::Base.any_instance.stubs(:profile_image_link).returns("some name")
    ActionView::Base.any_instance.stubs(:theme_option).returns(nil)
    ActionView::Base.any_instance.stubs(:font_awesome).returns("View All")

    render_block_footer(block)
    assert_select "a.view-all"
    assert_select "a[href=?]", "/profile/#{profile.name.to_slug}/members#members-tab"
  end

  should "provide link to members page when visible_role is profile_member" do
    env = fast_create(Environment)
    profile = fast_create(Community, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    member = fast_create(Person, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    relation = RoleAssignment.new(resource_id: profile.id, resource_type: "Profile", role_id: 3)
    relation.accessor = member
    relation.save
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.visible_role = "profile_member"
    block.expects(:owner).returns(profile.reload).at_least_once
    block.save!
    ActionView::Base.any_instance.stubs(:font_awesome).returns("View       All")
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    ActionView::Base.any_instance.stubs(:profile_image_link).returns("some name")
    ActionView::Base.any_instance.stubs(:theme_option).returns(nil)

    render_block_footer(block)
    assert_select "a.view-all"
    assert_select "a[href=?]", "/profile/#{profile.name.to_slug}/members#members-tab"
  end

  should "provide link to members page when visible_role is profile_moderator" do
    env = fast_create(Environment)
    profile = fast_create(Community, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    member = fast_create(Person, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    relation = RoleAssignment.new(resource_id: profile.id, resource_type: "Profile", role_id: 3)
    relation.accessor = member
    relation.save
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.visible_role = "profile_moderator"
    block.expects(:owner).returns(profile.reload).at_least_once
    block.save!

    ActionView::Base.any_instance.stubs(:font_awesome).returns("View       All")
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    ActionView::Base.any_instance.stubs(:profile_image_link).returns("some name")
    ActionView::Base.any_instance.stubs(:theme_option).returns(nil)

    render_block_footer(block)
    assert_select "a.view-all"
    assert_select "a[href=?]", "/profile/#{profile.name.to_slug}/members#members-tab"
  end

  should "provide link to admins page when visible_role is profile_admin" do
    env = fast_create(Environment)
    profile = fast_create(Community, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    member = fast_create(Person, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    relation = RoleAssignment.new(resource_id: profile.id, resource_type: "Profile", role_id: 3)
    relation.accessor = member
    relation.save
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.visible_role = "profile_admin"
    block.expects(:owner).returns(profile.reload).at_least_once
    block.save!
    ActionView::Base.any_instance.stubs(:font_awesome).returns("View       All")
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    ActionView::Base.any_instance.stubs(:profile_image_link).returns("some name")
    ActionView::Base.any_instance.stubs(:theme_option).returns(nil)
    render_block_footer(block).inspect

    assert_select "a.view-all"
    assert_select "a[href=?]", "/profile/#{profile.name.to_slug}/members#admins-tab"
  end

  # FIXME: This test is currently not reliable in the CI. We should rewrite it.
  # should 'not have a linear increase in time to display members block' do
  #   owner = fast_create(Community)
  #   owner.boxes<< Box.new
  #   block = MembersBlock.create!(:box => owner.boxes.first)

  #   ActionView::Base.any_instance.stubs(:profile_image_link).returns('some name')
  #   ActionView::Base.any_instance.stubs(:block_title).returns("")
  #   ActionView::Base.any_instance.stubs(:theme_option).returns(nil)

  #   # no people
  #   block.reload
  #   time0 = (Benchmark.measure { 10.times { render_block_content(block) } })

  #   1.upto(50).map do |n|
  #     p = create_user("user #{n}").person
  #     owner.add_member(p)
  #   end

  #   # first 50
  #   block.reload
  #   time1 = (Benchmark.measure { 10.times { render_block_content(block) } })

  #   1.upto(50).map do |n|
  #     p = create_user("user 1#{n}").person
  #     owner.add_member(p)
  #   end
  #   block.reload
  #   # another 50
  #   time2 = (Benchmark.measure { 10.times { render_block_content(block) } })

  #   # should not scale linearly, i.e. the inclination of the first segment must
  #   # be a lot higher than the one of the segment segment. To compensate for
  #   # small variations due to hardware and/or execution environment, we are
  #   # satisfied if the the inclination of the first segment is at least twice
  #   # the inclination of the second segment.
  #   a1 = (time1.total - time0.total)/50.0
  #   a2 = (time2.total - time1.total)/50.0
  #   assert a1 > a2*NON_LINEAR_FACTOR, "#{a1} should be larger than #{a2} by at least a factor of #{NON_LINEAR_FACTOR}"
  # end

  should "list members in api content" do
    owner = fast_create(Community)
    person1 = fast_create(Person)
    person2 = fast_create(Person)
    owner.add_member(person1)
    owner.add_member(person2)

    block = MembersBlock.new
    block.expects(:owner).returns(owner).at_least_once
    json = block.api_content
    assert_equivalent [person1.identifier, person2.identifier], json["people"].map { |p| p[:identifier] }
  end

  should "limit members list in api content" do
    owner = fast_create(Community)
    5.times do
      member = fast_create(Person)
      owner.add_member(member)
    end
    block = MembersBlock.new(limit: 3)
    block.expects(:owner).returns(owner.reload).at_least_once
    json = block.api_content
    assert_equal 3, json["people"].size
  end

  should "not list templates as community members" do
    env = fast_create(Environment)
    env.boxes << Box.new
    community = fast_create(Community)
    u1 = create_user
    u1.activate!
    p1 = u1.person
    community.add_member(p1)
    identifier = "fake_template"
    template = User.new(login: identifier, email: identifier + "@templates.noo", password: identifier, password_confirmation: identifier, person_data: { name: identifier, is_template: true }, environment_id: env.id)
    template.save!
    block = MembersBlock.new
    community.add_member(template.person)
    block.stubs(:owner).returns(community)
    env.boxes.first.blocks << block
    block.save!
    assert_equal 1, block.profile_list.size
  end

  should "return members randomically in api content" do
    owner = fast_create(Community)
    10.times do
      member = fast_create(Person)
      owner.add_member(member)
    end
    block = MembersBlock.new(limit: 3)
    block.expects(:owner).returns(owner.reload).at_least_once
    json_response_1 = block.api_content
    json_response_2 = block.api_content
    json_response_3 = block.api_content
    assert_not_equal json_response_1, json_response_2
    assert_not_equal json_response_2, json_response_3
  end

  should "return members in order of name in api content" do
    owner = fast_create(Community)
    3.times do |n|
      friend = fast_create(Person, name: "Person #{n}")
      owner.add_member(friend)
    end
    block = MembersBlock.new(limit: 3)
    block.expects(:owner).returns(owner.reload).at_least_once
    json_response = block.api_content
    assert (json_response["people"][0][:name] < json_response["people"][1][:name]) && (json_response["people"][1][:name] < json_response["people"][2][:name])
  end
end
