require File.dirname(__FILE__) + '/../test_helper'

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
    block = CommunitiesBlock.new

    owner = mock
    block.stubs(:owner).returns(owner)

    list = []
    owner.stubs(:communities).returns(list)

    assert_same list, block.profiles
  end

  should 'link to all communities of profile' do
    profile = Profile.new
    profile.expects(:identifier).returns("theprofile")

    block = CommunitiesBlock.new
    block.expects(:owner).returns(profile)

    expects(:link_to).with('View all', :controller => 'profile', :profile => 'theprofile', :action => 'communities')
    instance_eval(&block.footer)
  end

  should 'support environment as owner' do
    env = Environment.default
    block = CommunitiesBlock.new
    block.expects(:owner).returns(env)

    expects(:link_to).with('View all', :controller => "browse", :action => 'communities')

    instance_eval(&block.footer)
  end

  should 'give empty footer on unsupported owner type' do
    block = CommunitiesBlock.new
    block.expects(:owner).returns(1)
    assert_equal '', block.footer
  end

  should 'list non-public communities' do
    user = create_user('testuser').person

    public_community = fast_create(Community, :environment_id => Environment.default.id)
    public_community.add_member(user)

    private_community = fast_create(Community, :environment_id => Environment.default.id, :public_profile => false)
    private_community.add_member(user)

    block = CommunitiesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equivalent [public_community, private_community], block.profiles
  end

end
