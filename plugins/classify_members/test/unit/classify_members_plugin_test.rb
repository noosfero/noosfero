require File.dirname(__FILE__) + '/../../../../test/test_helper'

class ClassifyMembersPluginTest < ActiveSupport::TestCase
  def setup
    @env = fast_create(Environment)
    @p1  = fast_create(Person, :environment_id => @env.id)
    @c1  = fast_create(Community, :environment_id => @env.id)
    @c2  = fast_create(Community, :environment_id => @env.id)
    @c3  = fast_create(Community, :environment_id => @env.id)
    @plugin = ClassifyMembersPlugin.new self
  end

  def environment
    @env
  end

  should 'not crash for nil setting' do
    assert_equal [], @plugin.find_community(@p1)
  end

  should 'list all classification communities' do
    @plugin.settings.communities = "
    #{@c1.identifier}: Tag1
    #{@c2.identifier}
    "
    @env.save!

    assert_equal [[@c1, 'Tag1'], [@c2, @c2.name]], @plugin.communities
  end

  should 'list the classification communities for a person' do
    @c1.add_member @p1
    @c2.add_member @p1
    @p1.stubs(:is_member_of?).returns(false)
    @p1.stubs(:is_member_of?).with(@c1).returns(true)
    @p1.stubs(:is_member_of?).with(@c2).returns(true)
    @plugin.settings.communities = "
    #{@c1.identifier}: Tag1
    #{@c2.identifier}: Tag2
    #{@c3.identifier}: Tag3
    "
    @env.save!

    assert_equal [[@c1, 'Tag1'], [@c2, 'Tag2']], @plugin.find_community(@p1)
  end
end
