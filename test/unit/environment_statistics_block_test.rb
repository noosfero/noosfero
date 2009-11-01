require File.dirname(__FILE__) + '/../test_helper'

class EnvironmentStatisticsBlockTest < Test::Unit::TestCase

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
  
  should 'generate statistics but not for private profiles' do
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

    assert_match /One enterprise/, content
    assert_match /2 users/, content
    assert_match /One community/, content
  end

end
