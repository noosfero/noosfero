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

    owner = mock
    block.expects(:owner).at_least_once.returns(owner)

    list = []
    owner.expects(:enterprises).returns(list)

    assert_same list, block.profiles
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

    assert_equal 2, block.profile_count
  end

end

require 'boxes_helper'

class EnterprisesBlockViewTest < ActionView::TestCase
  include BoxesHelper

  should 'link to all enterprises for profile' do
    profile = Profile.new
    profile.identifier = 'theprofile'
    block = EnterprisesBlock.new
    block.expects(:owner).twice.returns(profile)

    ActionView::Base.any_instance.expects(:link_to).with('View all', :controller => 'profile', :profile => 'theprofile', :action => 'enterprises')

    render_block_footer(block)
  end

  should 'link to all enterprises for environment' do
    env = Environment.default
    block = EnterprisesBlock.new
    block.expects(:owner).twice.returns(env)

    ActionView::Base.any_instance.expects(:link_to).with('View all', :controller => 'search', :action => 'assets', :asset => 'enterprises')
    render_block_footer(block)
  end

  should 'give empty footer for unsupported owner type' do
    block = EnterprisesBlock.new
    block.expects(:owner).twice.returns(1)
    assert_equal '', render_block_footer(block)
  end
end
