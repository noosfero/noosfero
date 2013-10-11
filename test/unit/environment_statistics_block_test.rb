require File.dirname(__FILE__) + '/../test_helper'

class EnvironmentStatisticsBlockTest < ActiveSupport::TestCase

  should 'inherit from Block' do
    assert_kind_of Block, EnvironmentStatisticsBlock.new
  end

  should 'describe itself' do
    assert_not_equal Block.description, EnvironmentStatisticsBlock.description
  end

  should 'provide a default title' do
    owner = mock
    owner.expects(:name).returns('my environment')

    block = EnvironmentStatisticsBlock.new
    block.expects(:owner).returns(owner)
    assert_equal 'Statistics for my environment', block.title
  end

  should 'generate statistics' do
    env = create(Environment)
    user1 = create_user('testuser1', :environment_id => env.id)
    user2 = create_user('testuser2', :environment_id => env.id)

    fast_create(Enterprise, :environment_id => env.id)
    fast_create(Community, :environment_id => env.id)

    block = EnvironmentStatisticsBlock.new
    env.boxes.first.blocks << block

    content = block.content

    assert_match(/One enterprise/, content)
    assert_match(/2 users/, content)
    assert_match(/One community/, content)
  end
  
  should 'generate statistics including private profiles' do
    env = create(Environment)
    user1 = create_user('testuser1', :environment_id => env.id)
    user2 = create_user('testuser2', :environment_id => env.id)
    user3 = create_user('testuser3', :environment_id => env.id)
    p = user3.person; p.public_profile = false; p.save!

    fast_create(Enterprise, :environment_id => env.id)
    fast_create(Enterprise, :environment_id => env.id, :public_profile => false)

    fast_create(Community, :environment_id => env.id)
    fast_create(Community, :environment_id => env.id, :public_profile => false)

    block = EnvironmentStatisticsBlock.new
    env.boxes.first.blocks << block

    content = block.content

    assert_match /2 enterprises/, content
    assert_match /3 users/, content
    assert_match /2 communities/, content
  end

  should 'generate statistics but not for not visible profiles' do
    env = create(Environment)
    user1 = create_user('testuser1', :environment_id => env.id)
    user2 = create_user('testuser2', :environment_id => env.id)
    user3 = create_user('testuser3', :environment_id => env.id)
    p = user3.person; p.visible = false; p.save!

    fast_create(Enterprise, :environment_id => env.id)
    fast_create(Enterprise, :environment_id => env.id, :visible => false)

    fast_create(Community, :environment_id => env.id)
    fast_create(Community, :environment_id => env.id, :visible => false)

    block = EnvironmentStatisticsBlock.new
    env.boxes.first.blocks << block

    content = block.content

    assert_match /One enterprise/, content
    assert_match /2 users/, content
    assert_match /One community/, content
  end

  should 'not display enterprises if disabled' do
    env = Environment.new
    env.enable('disable_asset_enterprises', false)

    block = EnvironmentStatisticsBlock.new
    block.stubs(:owner).returns(env)

    assert_no_match /enterprises/i, block.content
  end

end
