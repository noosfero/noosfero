require_relative "../test_helper"

class MainBlockTest < ActiveSupport::TestCase

  should 'describe itself' do
    assert_kind_of String, MainBlock.description
    assert_not_equal Block.description, MainBlock.description
  end

  should 'have no content' do
    ok("MainBlock must not have a content") { MainBlock.new.content.blank? }
  end

  should 'be editable' do
    assert MainBlock.new.editable?
  end

  should 'be visible on environment' do
    env = Environment.new
    block = MainBlock.new
    block.stubs(:owner).returns(env)
    assert block.visible?
  end

  should 'not be visible on environment' do
    env = Environment.new
    block = MainBlock.new(:display => 'never')
    block.stubs(:owner).returns(env)
    refute block.visible?
  end

  should 'guarantee main block is always visible to everybody' do
    assert_equal MainBlock.new.display_user_options, {"all"=>_('All users')}
  end

end
