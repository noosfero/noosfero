require File.dirname(__FILE__) + '/../test_helper'

class PeopleBlockPluginTest < ActiveSupport::TestCase

  should "return PeopleBlock in extra_blocks class method" do
    assert PeopleBlockPlugin.extra_blocks.keys.include?(PeopleBlock)
  end

  should "return MembersBlock in extra_blocks class method" do
    assert PeopleBlockPlugin.extra_blocks.keys.include?(MembersBlock)
  end

  should "return FriendsBlock in extra_blocks class method" do
    assert PeopleBlockPlugin.extra_blocks.keys.include?(FriendsBlock)
  end

  should "return false for class method has_admin_url?" do
    assert !PeopleBlockPlugin.has_admin_url?
  end

  should "return false for class method stylesheet?" do
    assert PeopleBlockPlugin.new.stylesheet?
  end

end
