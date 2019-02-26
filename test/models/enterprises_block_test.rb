require_relative "../test_helper"

class EnterprisesBlockTest < ActiveSupport::TestCase

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

  should 'list owner enterprises' do
    block = EnterprisesBlock.new
    owner = fast_create(Person)

    e1 = fast_create(Enterprise)
    e1.add_member(owner)
    e2 = fast_create(Enterprise)
    e2.add_member(owner)
    e3 = fast_create(Enterprise)

    block.expects(:owner).at_least_once.returns(owner)

    assert_equivalent [e1,e2], block.profiles(owner)
  end

  should 'count number of owner enterprises' do
    user = create_user('testuser').person

    ent1 = fast_create(Enterprise, :name => 'test enterprise 1', :identifier => 'ent1')
    ent1.expects(:closed?).returns(false)
    ent1.add_member(user)

    ent2 = fast_create(Enterprise, :name => 'test enterprise 2', :identifier => 'ent2')
    ent2.expects(:closed?).returns(false)
    ent2.add_member(user)

    block = EnterprisesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equal 2, block.profile_count(user)
  end

  should 'have Enterprise as base class' do
    assert_equal Enterprise, EnterprisesBlock.new.send(:base_class)
  end

end

require 'boxes_helper'

class EnterprisesBlockViewTest < ActionView::TestCase
  include BoxesHelper

  should 'link to all enterprises for profile' do
    env = fast_create(Environment)
    enterprise = fast_create(Enterprise, :environment_id => env.id, user_id: fast_create(User, activated_at: DateTime.now).id)
    profile = fast_create(Person, :environment_id => env.id, user_id: fast_create(User, activated_at: DateTime.now).id)

    relation = RoleAssignment.new(:resource_id => enterprise.id, :resource_type => 'Profile', :role_id => 3)
    relation.accessor = profile
    relation.save

    block = EnterprisesBlock.new
    block.expects(:owner).returns(profile).at_least_once

    ActionView::Base.any_instance.stubs(:font_awesome).returns("View all")
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    ActionView::Base.any_instance.stubs(:profile_image_link).returns('some name')
    ActionView::Base.any_instance.stubs(:theme_option).returns(nil)

    render_block_footer(block)
    assert_select 'a.view-all' do |elements|
      assert_select "[href=\"/profile/#{profile.identifier}/enterprises\"]"
    end
  end

  should 'link to all enterprises for environment' do
    env = fast_create(Environment)
    enterprise = fast_create(Enterprise, :environment_id => env.id, user_id: fast_create(User, activated_at: DateTime.now).id)

    block = EnterprisesBlock.new
    block.expects(:owner).returns(env).at_least_once

    ActionView::Base.any_instance.stubs(:font_awesome).returns("View all")
    ActionView::Base.any_instance.stubs(:font_awesome).returns("View       All")
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    ActionView::Base.any_instance.stubs(:profile_image_link).returns('some name')
    ActionView::Base.any_instance.stubs(:theme_option).returns(nil)

    footer = render_block_footer(block)
    assert_tag_in_string footer, tag: 'a', attributes: {href: "/search/assets?asset=enterprises"}
  end

  should 'give empty footer for unsupported owner type' do
    block = EnterprisesBlock.new
    block.expects(:owner).twice.returns(1)
    assert_equal '', render_block_footer(block)
  end
end
