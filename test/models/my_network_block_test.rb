require_relative "../test_helper"

class MyNetworkBlockTest < ActiveSupport::TestCase

  def setup
    @block = MyNetworkBlock.new
    @owner = Person.new(:identifier => 'testuser')
    @block.stubs(:owner).returns(@owner)

    owner.stubs(:environment).returns(Environment.default)
  end
  attr_reader :owner, :block

  should 'provide description' do
    assert_not_equal Block.description, MyNetworkBlock.description
  end

  should 'provide default title' do
    assert_not_equal Block.new.default_title, MyNetworkBlock.new.default_title
  end

  should 'be able to update display setting' do
    user = create_user('testinguser').person
    box = fast_create(Box, :owner_id => user.id)
    block = MyNetworkBlock.create!(:display => 'never', :box => box)
    assert block.update!(:display => 'always')
    block.reload
    assert_equal 'always', block.display
  end

end

class MyNetworkBlockViewTest < ActionView::TestCase
  include BoxesHelper

  def setup
    @block = MyNetworkBlock.new
    @owner = Person.new(:identifier => 'testuser')
    @block.stubs(:owner).returns(@owner)
    owner.stubs(:environment).returns(Environment.default)
  end
  attr_reader :owner, :block

  should 'display my-profile' do
    ActionView::Base.any_instance.stubs(:block_title).with(anything, anything).returns(true)
    ActionView::Base.any_instance.stubs(:user).with(anything).returns(owner)
    ActionView::Base.any_instance.stubs(:render_profile_actions)
    assert_match "#{Environment.default.top_url}/profile/testuser", render_block_content(block)
  end
end
