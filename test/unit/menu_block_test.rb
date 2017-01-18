require_relative "../test_helper"

class MenuBlockTest < ActiveSupport::TestCase

  should 'default describe' do
    assert_not_equal Block.description, MenuBlock.description
  end

  should 'is editable' do
    l = MenuBlock.new
    assert l.editable?
  end

end
