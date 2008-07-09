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
    env = Environment.create!(:name => "My test environment")
    user1 = create_user('testuser1', :environment_id => env.id)
    user2 = create_user('testuser2', :environment_id => env.id)

    env.enterprises.build(:identifier => 'mytestenterprise', :name => 'My test enterprise').save!

    env.communities.build(:identifier => 'mytestcommunity', :name => 'mytestcommunity').save!

    block = EnvironmentStatisticsBlock.new
    env.boxes.first.blocks << block

    content = block.content

    assert_match /One enterprise/, content
    assert_match /2 users/, content
    assert_match /One community/, content
  end

end
