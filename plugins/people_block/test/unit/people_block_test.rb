require_relative "../test_helper"

class PeopleBlockTest < ActionView::TestCase
  should "inherit from Block" do
    assert_kind_of Block, PeopleBlock.new
  end

  should "declare its default title" do
    assert_not_equal Block.new.default_title, PeopleBlock.new.default_title
  end

  should "describe itself" do
    assert_not_equal Block.description, PeopleBlock.description
  end

  should "is editable" do
    block = PeopleBlock.new
    assert block.editable?
  end

  should "have field limit" do
    block = PeopleBlock.new
    assert_respond_to block, :limit
  end

  should "default value of limit" do
    block = PeopleBlock.new
    assert_equal 6, block.limit
  end

  should "have field name" do
    block = PeopleBlock.new
    assert_respond_to block, :name
  end

  should "default value of name" do
    block = PeopleBlock.new
    assert_equal "", block.name
  end

  should "have field address" do
    block = PeopleBlock.new
    assert_respond_to block, :address
  end

  should "default value of address" do
    block = PeopleBlock.new
    assert_equal "", block.address
  end

  should "prioritize profiles with image by default" do
    assert PeopleBlock.new.prioritize_profiles_with_image
  end

  should "respect limit when listing people" do
    env = fast_create(Environment)

    p1 = create_user("p1", environment: env, activated_at: DateTime.now).person
    p2 = create_user("p2", environment: env, activated_at: DateTime.now).person
    p3 = create_user("p3", environment: env, activated_at: DateTime.now).person
    p4 = create_user("p4", environment: env, activated_at: DateTime.now).person

    block = PeopleBlock.new(limit: 3)
    block.stubs(:owner).returns(env)

    assert_equal 3, block.profile_list.size
  end

  should "accept a limit of people to be displayed" do
    block = PeopleBlock.new
    block.limit = 20
    assert_equal 20, block.limit
  end

  should "count number of public and private people" do
    owner = fast_create(Environment)

    private_p = fast_create(Person, access: Entitlement::Levels.levels[:related], environment_id: owner.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    public_p = fast_create(Person, environment_id: owner.id, user_id: fast_create(User, activated_at: DateTime.now).id)

    friend = fast_create(Person)
    friend.add_friend(private_p)

    block = PeopleBlock.new
    block.expects(:owner).returns(owner).at_least_once

    assert_equal 1, block.profile_count
    assert_equal 2, block.profile_count(friend)
  end

  should "not count number of invisible people" do
    owner = fast_create(Environment)
    private_p = fast_create(Person, visible: false, environment_id: owner.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    public_p = fast_create(Person, visible: true, environment_id: owner.id, user_id: fast_create(User, activated_at: DateTime.now).id)

    block = PeopleBlock.new
    block.expects(:owner).returns(owner).at_least_once

    assert_equal 1, block.profile_count
  end

  protected

    include NoosferoTestHelper
end

require "boxes_helper"

class PeopleBlockViewTest < ActionView::TestCase
  include BoxesHelper

  def setup
    view.stubs(:user).returns(nil)
  end

  should "list people from environment" do
    owner = fast_create(Environment)
    person1 = fast_create(Person, environment_id: owner.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    person2 = fast_create(Person, environment_id: owner.id, user_id: fast_create(User, activated_at: DateTime.now).id)

    block = PeopleBlock.new

    block.expects(:owner).returns(owner).at_least_once
    ActionView::Base.any_instance.expects(:profile_image_link).with(person1, :minor).returns(person1.name)
    ActionView::Base.any_instance.expects(:profile_image_link).with(person2, :minor).returns(person2.name)
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    ActionView::Base.any_instance.stubs(:theme_option).returns(nil)

    content = render_block_content(block)

    assert_match(/#{person1.name}/, content)
    assert_match(/#{person2.name}/, content)
  end

  should 'link to "all people" on people block' do
    env = fast_create(Environment)
    fast_create(Person, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    fast_create(Person, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    fast_create(Person, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    block = PeopleBlock.new
    block.expects(:owner).returns(env).at_least_once

    ActionView::Base.any_instance.stubs(:font_awesome).returns("View       All")
    render_block_footer(block)
    assert_select "a.view-all" do |elements|
      assert_select "[href=\"/search/people\"]"
    end
  end

  should 'show link to "all people" on friends block' do
    env = fast_create(Environment)
    profile = fast_create(Person, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    friend = fast_create(Person, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    profile.add_friend(friend)
    profile.save!
    block = FriendsBlock.new
    block.expects(:owner).returns(profile.reload).at_least_once

    ActionView::Base.any_instance.stubs(:font_awesome).returns("View       All")
    render_block_footer(block)
    assert_select "a.view-all"
    assert_select "a[href=?]", "/profile/#{profile.name.to_slug}/friends"
  end

  should 'show link to "all people" on members block' do
    env = fast_create(Environment)
    profile = fast_create(Community, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    member = fast_create(Person, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    relation = RoleAssignment.new(resource_id: profile.id, resource_type: "Profile", role_id: 3)
    relation.accessor = member
    relation.save
    block = MembersBlock.new
    block.expects(:owner).returns(profile.reload).at_least_once

    ActionView::Base.any_instance.stubs(:font_awesome).returns("View       All")
    render_block_footer(block)
    assert_select "a.view-all"
    assert_select "a[href=?]", "/profile/#{profile.name.to_slug}/members#members-tab"
  end

  should 'Not show link to "all people" if the people block is empty' do
    env = fast_create(Environment)
    block = PeopleBlock.new
    block.expects(:owner).returns(env).at_least_once

    ActionView::Base.any_instance.stubs(:font_awesome).returns("View       All")
    assert_equal "\n", render_block_footer(block)
  end

  should 'Not show link to "all members" if the members block is empty' do
    env = fast_create(Community)
    profile = fast_create(Community, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    block = MembersBlock.new
    block.expects(:owner).returns(profile).at_least_once

    assert_equal "\n\n\n", render_block_footer(block)
  end

  should 'Not show link to "all friends" if the friends block is empty' do
    profile = fast_create(Person)
    block = FriendsBlock.new
    block.expects(:owner).returns(profile).at_least_once

    assert_equal "\n\n", render_block_footer(block)
  end

  # FIXME: This test is currently not reliable in the CI. We should rewrite it.
  # should 'not have a linear increase in time to display people block' do
  #   owner = fast_create(Environment)
  #   owner.boxes<< Box.new
  #   block = PeopleBlock.create!(:box => owner.boxes.first)

  #   ActionView::Base.any_instance.stubs(:profile_image_link).returns('some name')
  #   ActionView::Base.any_instance.stubs(:block_title).returns("")
  #   ActionView::Base.any_instance.stubs(:theme_option).returns(nil)

  #   # no people
  #   block.reload
  #   time0 = (Benchmark.measure { 10.times { render_block_content(block) } })

  #   # first 500
  #   1.upto(50).map do
  #     fast_create(Person, :environment_id => owner.id)
  #   end
  #   block.reload
  #   time1 = (Benchmark.measure { 10.times { render_block_content(block) } })

  #   # another 50
  #   1.upto(50).map do
  #     fast_create(Person, :environment_id => owner.id)
  #   end
  #   block.reload
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

  should "list people api content" do
    owner = fast_create(Environment)
    person1 = fast_create(Person, environment_id: owner.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    person2 = fast_create(Person, environment_id: owner.id, user_id: fast_create(User, activated_at: DateTime.now).id)

    block = PeopleBlock.new
    block.expects(:owner).returns(owner).at_least_once
    json = block.api_content
    assert_equivalent [person1.identifier, person2.identifier], json["people"].map { |p| p[:identifier] }
  end

  should "limit people list in api content" do
    owner = fast_create(Environment)
    5.times do
      fast_create(Person, environment_id: owner.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    end
    block = PeopleBlock.new(limit: 3)
    block.expects(:owner).returns(owner.reload).at_least_once
    json = block.api_content
    assert_equal 3, json["people"].size
    assert_equal 5, json["#"]
  end

  should "not list person template from environment" do
    owner = fast_create(Environment)
    person1 = fast_create(Person, environment_id: owner.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    person2 = fast_create(Person, environment_id: owner.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    template = fast_create(Person, environment_id: owner.id, is_template: true, user_id: fast_create(User, activated_at: DateTime.now).id)
    block = PeopleBlock.new
    block.expects(:owner).returns(owner).at_least_once
    assert_equal 2, block.profile_list.count
  end

  should "return people randomically in api content" do
    owner = fast_create(Environment)
    5.times do
      fast_create(Person, environment_id: owner.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    end
    block = PeopleBlock.new(limit: 3)
    block.expects(:owner).returns(owner.reload).at_least_once
    json_response_1 = block.api_content
    json_response_2 = block.api_content
    json_response_3 = block.api_content
    assert !(json_response_1 == json_response_2 && json_response_2 == json_response_3)
  end

  should "return people in order of name in api content" do
    owner = fast_create(Environment)
    3.times do
      fast_create(Person, environment_id: owner.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    end
    block = PeopleBlock.new(limit: 3)
    block.expects(:owner).returns(owner.reload).at_least_once
    json_response = block.api_content
    assert (json_response["people"][0][:name] < json_response["people"][1][:name]) && (json_response["people"][1][:name] < json_response["people"][2][:name])
  end

  should "not list inactive people" do
    owner = fast_create(Environment)
    person1 = create_user("john", environment: owner).person
    person2 = create_user("andrew", environment: owner).person
    person2.user.deactivate
    person2.reload
    block = PeopleBlock.new
    block.expects(:owner).returns(owner).at_least_once
    assert_equal [person1.id], block.profile_list.map(&:id)
  end
end
