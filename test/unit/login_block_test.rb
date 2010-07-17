require File.dirname(__FILE__) + '/../test_helper'

class LoginBlockTest < ActiveSupport::TestCase

  def setup
    @block = LoginBlock.new
  end
  attr_reader :block

  should 'describe itself' do
    assert_not_equal Block.description, LoginBlock.description
  end

  should 'point to account/login_block' do
    self.expects(:logged_in?).returns(false)
    self.expects(:render).with(:file => 'account/login_block')
    self.instance_eval(& block.content)
  end

  should 'display user_info if not logged' do
    self.expects(:logged_in?).returns(true)
    self.expects(:render).with(:file => 'account/user_info')
    self.instance_eval(& block.content)
  end

end
