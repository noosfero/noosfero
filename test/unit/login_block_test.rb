require File.dirname(__FILE__) + '/../test_helper'

class LoginBlockTest < Test::Unit::TestCase

  def setup
    @block = LoginBlock.new
  end
  attr_reader :block

  should 'describe itself' do
    assert_not_equal Block.description, LoginBlock.description
  end

  should 'point to account/login_block' do
    assert_equal({ :controller => 'account', :action => 'login_block' }, block.content)
  end

end
