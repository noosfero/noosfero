require_relative "../test_helper"

class FriendsBlockTest < ActionView::TestCase
  should "inherit from Block" do
    assert_kind_of Block, FriendsBlock.new
  end

  should "declare its default title" do
    FriendsBlock.any_instance.expects(:profile_count).returns(0)
    assert_not_equal Block.new.default_title, FriendsBlock.new.default_title
  end

  should "describe itself" do
    assert_not_equal Block.description, FriendsBlock.description
  end

  should "is editable" do
    block = FriendsBlock.new
    assert block.editable?
  end

  should "have field limit" do
    block = FriendsBlock.new
    assert_respond_to block, :limit
  end

  should "default value of limit" do
    block = FriendsBlock.new
    assert_equal 6, block.limit
  end

  should "have field name" do
    block = FriendsBlock.new
    assert_respond_to block, :name
  end

  should "default value of name" do
    block = FriendsBlock.new
    assert_equal "", block.name
  end

  should "have field address" do
    block = FriendsBlock.new
    assert_respond_to block, :address
  end

  should "default value of address" do
    block = FriendsBlock.new
    assert_equal "", block.address
  end

  should "prioritize profiles with image by default" do
    assert FriendsBlock.new.prioritize_profiles_with_image
  end

  should "accept a limit of people to be displayed" do
    block = FriendsBlock.new
    block.limit = 20
    assert_equal 20, block.limit
  end

  should "count number of owner friends" do
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

  should "count number of public and private friends" do
    owner = fast_create(Person)
    private_p = fast_create(Person, access: Entitlement::Levels.levels[:related])
    public_p = fast_create(Person)

    owner.add_friend(private_p)
    owner.add_friend(public_p)

    block = FriendsBlock.new
    block.expects(:owner).returns(owner).at_least_once

    assert_equal 1, block.profile_count
    assert_equal 2, block.profile_count(owner)
  end

  should "not count number of invisible friends" do
    owner = fast_create(Person)
    private_p = fast_create(Person, visible: false)
    public_p = fast_create(Person, visible: true)

    owner.add_friend(private_p)
    owner.add_friend(public_p)

    block = FriendsBlock.new
    block.expects(:owner).returns(owner).at_least_once

    assert_equal 1, block.profile_count
  end

  should "list owner's friends suggestions" do
    owner = fast_create(Person)
    suggestion1 = ProfileSuggestion.create!(suggestion: fast_create(Person), person: owner)
    suggestion2 = ProfileSuggestion.create!(suggestion: fast_create(Person), person: owner)

    block = FriendsBlock.new
    block.stubs(:owner).returns(owner)

    assert_equivalent block.suggestions, [suggestion1, suggestion2]
  end

  should "not list templates as friends" do
    owner = fast_create(Person)
    friend1 = fast_create(Person)
    template = fast_create(Person, is_template: true)
    owner.add_friend(friend1)
    owner.add_friend(template)
    block = FriendsBlock.new
    block.expects(:owner).returns(owner).at_least_once
    assert_equal 1, block.profile_count
  end

  protected

    include NoosferoTestHelper
end

require "boxes_helper"

class FriendsBlockViewTest < ActionView::TestCase
  include BoxesHelper

  def setup
    view.stubs(:user).returns(nil)
  end

  should "list friends from person" do
    owner = fast_create(Person)
    u = create_user
    u.activate!
    friend1 = u.person

    u = create_user
    u.activate!
    friend2 = u.person

    owner.add_friend(friend1)
    owner.add_friend(friend2)

    block = FriendsBlock.new

    block.expects(:owner).returns(owner).at_least_once
    ActionView::Base.any_instance.expects(:profile_image_link).with(friend1, :minor).returns(friend1.name)
    ActionView::Base.any_instance.expects(:profile_image_link).with(friend2, :minor).returns(friend2.name)
    ActionView::Base.any_instance.expects(:block_title).with(anything, anything).returns("")
    ActionView::Base.any_instance.stubs(:theme_option).returns(nil)

    content = render_block_content(block)

    assert_match(/#{friend1.name}/, content)
    assert_match(/#{friend2.name}/, content)
  end

  should 'link to "all friends"' do
    env = fast_create(Environment)
    person1 = fast_create(Person, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    friend = fast_create(Person, environment_id: env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    person1.add_friend(friend)
    person1.save!

    block = FriendsBlock.new
    block.stubs(:suggestions).returns([])
    block.expects(:owner).returns(person1).at_least_once
    ActionView::Base.any_instance.stubs(:font_awesome).returns("View All")
    assert_tag_in_string render_block_footer(block), tag: "a", attributes: { class: "view-all", href: "/profile/#{person1.identifier}/friends" }
  end

  # FIXME: This test is currently not reliable in the CI. We should rewrite it.
  # should 'not have a linear increase in time to display friends block' do
  #   owner = fast_create(Person)
  #   owner.boxes<< Box.new
  #   block = FriendsBlock.create!(:box => owner.boxes.first)

  #   ActionView::Base.any_instance.stubs(:profile_image_link).returns('some name')
  #   ActionView::Base.any_instance.stubs(:block_title).returns("")
  #   ActionView::Base.any_instance.stubs(:theme_option).returns(nil)

  #   # no people
  #   block.reload
  #   time0 = (Benchmark.measure { 10.times { render_block_content(block) } })

  #   # first 50
  #   1.upto(50).map do |n|
  #     p = create_user("user #{n}").person
  #     owner.add_friend(p)
  #   end
  #   block.reload
  #   time1 = (Benchmark.measure { 10.times { render_block_content(block) } })

  #   # another 50
  #   1.upto(50).map do |n|
  #     p = create_user("user #{n}").person
  #     owner.add_friend(p)
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

  should "list friends in api content" do
    owner = fast_create(Person)
    friend1 = fast_create(Person)
    friend2 = fast_create(Person)
    owner.add_friend(friend1)
    owner.add_friend(friend2)
    block = FriendsBlock.new
    block.expects(:owner).returns(owner).at_least_once
    json = block.api_content
    assert_equivalent [friend1.identifier, friend2.identifier], json["people"].map { |p| p[:identifier] }
  end

  should "limit friends list in api content" do
    owner = fast_create(Person)
    5.times do
      friend = fast_create(Person)
      owner.add_friend(friend)
    end
    block = FriendsBlock.new(limit: 3)
    block.expects(:owner).returns(owner.reload).at_least_once
    json = block.api_content
    assert_equal 3, json["people"].size
    assert_equal 5, json["#"]
  end

  should "return friends randomically in api content" do
    owner = fast_create(Person)
    10.times do |n|
      friend = fast_create(Person, name: "Person #{n}")
      owner.add_friend(friend)
    end
    block = FriendsBlock.new(limit: 3)
    block.expects(:owner).returns(owner.reload).at_least_once
    json_response_1 = block.api_content
    json_response_2 = block.api_content
    json_response_3 = block.api_content
    assert_not_equal json_response_1, json_response_2
    assert_not_equal json_response_2, json_response_3
  end

  should "return friends in order of name in api content" do
    owner = fast_create(Person)
    10.times do |n|
      friend = fast_create(Person, name: "Person #{n}")
      owner.add_friend(friend)
    end
    block = FriendsBlock.new(limit: 3)
    block.expects(:owner).returns(owner.reload).at_least_once
    json_response = block.api_content
    assert (json_response["people"][0][:name] < json_response["people"][1][:name]) && (json_response["people"][1][:name] < json_response["people"][2][:name])
  end
end
