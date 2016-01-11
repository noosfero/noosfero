require_relative "../test_helper"

class SellersSearchBlockTest < ActiveSupport::TestCase

  should 'provide description' do
    assert_not_equal Block.description, SellersSearchBlock.description
  end

  should 'provide default title' do
    assert_not_equal Block.new.default_title, SellersSearchBlock.new.default_title
  end

end
