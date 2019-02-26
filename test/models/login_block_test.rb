require_relative "../test_helper"

class LoginBlockTest < ActiveSupport::TestCase

  def setup
    @block = LoginBlock.new
  end
  attr_reader :block

  should 'describe itself' do
    assert_not_equal Block.description, LoginBlock.description
  end

end
