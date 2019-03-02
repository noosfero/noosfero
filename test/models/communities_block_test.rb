require_relative "../test_helper"

class CommunitiesBlockTest < ActiveSupport::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, CommunitiesBlock.new
  end

  should 'declare its default title' do
    CommunitiesBlock.any_instance.stubs(:profile_count).returns(0)
    assert_not_equal ProfileListBlock.new.default_title, CommunitiesBlock.new.default_title
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, CommunitiesBlock.description
  end

  should 'list owner communities' do
    owner = fast_create(Person)
    community1 = fast_create(Community)
    community2 = fast_create(Community)
    community1.add_member(owner)
    community2.add_member(owner)

    block = CommunitiesBlock.new
    block.expects(:owner).returns(owner).at_least_once
    json = block.api_content
    assert_equivalent [community1.identifier, community2.identifier], json["communities"].map {|p| p[:identifier]}
  end

  should 'list non-public communities' do
    user = create_user('testuser').person

    public_community = fast_create(Community, :environment_id => Environment.default.id)
    public_community.add_member(user)

    private_community = fast_create(Community, :environment_id => Environment.default.id, :access => Entitlement::Levels.levels[:related])
    private_community.add_member(user)

    block = CommunitiesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equivalent [public_community, private_community], block.profiles(user)
  end

  should 'have Community as base class' do
    assert_equal Community, CommunitiesBlock.new.send(:base_class)
  end

end

require 'boxes_helper'

class CommunitiesBlockViewTest < ActionView::TestCase
  include BoxesHelper

  should 'support profile as block owner' do
    env = fast_create(Environment)
    community = fast_create(Community, :environment_id => env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    profile = fast_create(Person, :environment_id => env.id, user_id: fast_create(User, activated_at: DateTime.now).id)

    relation = RoleAssignment.new(:resource_id => community.id, :resource_type => 'Profile', :role_id => 3)
    relation.accessor = profile
    relation.save

    block = CommunitiesBlock.new
    block.box = env.boxes.first
    block.save
    block.expects(:owner).returns(profile).at_least_once

    ActionView::Base.any_instance.stubs(:font_awesome).returns("View       All")
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    ActionView::Base.any_instance.stubs(:profile_image_link).returns('some name')
    ActionView::Base.any_instance.stubs(:theme_option).returns(nil)

    ActionView::Base.any_instance.stubs(:user).with(anything).returns(profile)
    ActionView::Base.any_instance.stubs(:profile).with(anything).returns(profile)

    footer = render_block_footer(block)

    assert_tag_in_string footer, tag: 'a', attributes: {href: "/profile/#{profile.identifier}/communities"}

    ActionView::Base.any_instance.unstub(:user)
    ActionView::Base.any_instance.unstub(:profile)
  end

  should 'support environment as block owner' do
    env = Environment.default
    profile = fast_create(Community, :environment_id => env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    member = fast_create(Person, :environment_id => env.id, user_id: fast_create(User, activated_at: DateTime.now).id)

    block = CommunitiesBlock.new
    block.box = env.boxes.first
    block.save
    block.expects(:owner).returns(env).at_least_once

    ActionView::Base.any_instance.stubs(:font_awesome).returns("View       All")
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    ActionView::Base.any_instance.stubs(:profile_image_link).returns('some name')
    ActionView::Base.any_instance.stubs(:theme_option).returns(nil)


    ActionView::Base.any_instance.stubs(:user).with(anything).returns(profile)
    ActionView::Base.any_instance.stubs(:profile).with(anything).returns(env)

    footer = render_block_footer(block)

    assert_tag_in_string footer, tag: 'a', attributes: {href: '/search/communities'}

    ActionView::Base.any_instance.unstub(:user)
    ActionView::Base.any_instance.unstub(:profile)
  end

  should 'give empty footer on unsupported owner type' do
    block = CommunitiesBlock.new
    block.expects(:owner).returns(1).at_least_once

    assert_equal '', render_block_footer(block)
  end

  should 'list communities in api content' do
    owner = fast_create(Person)
    community1 = fast_create(Community)
    community2 = fast_create(Community)
    community1.add_member(owner)
    community2.add_member(owner)
    block = CommunitiesBlock.new
    block.expects(:owner).returns(owner).at_least_once
    json = block.api_content
    assert_equivalent [community1.identifier, community2.identifier], json["communities"].map {|p| p[:identifier]}
  end

  should 'limit communities list in api content' do
    owner = fast_create(Person)
    5.times do
      community = fast_create(Community)
      community.add_member(owner)
    end
    block = CommunitiesBlock.new(limit: 3)
    block.expects(:owner).returns(owner.reload).at_least_once
    json = block.api_content
    assert_equal 3, json["communities"].size
    assert_equal 5, json["#"]
  end

  should 'not list communities templates in api content' do
    owner = fast_create(Person)
    community1 = fast_create(Community)
    community2 = fast_create(Community, :is_template => true)
    community1.add_member(owner)
    community2.add_member(owner)
    block = CommunitiesBlock.new
    block.expects(:owner).returns(owner).at_least_once
    json = block.api_content
    assert_equivalent [community1.identifier], json["communities"].map {|p| p[:identifier]}
  end

end
