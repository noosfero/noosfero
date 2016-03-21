require_relative "../test_helper"
require 'boxes_helper'

class ProfileImageBlockTest < ActiveSupport::TestCase
  include BoxesHelper

  should 'provide description' do
    assert_not_equal Block.description, ProfileImageBlock.description
  end

  should 'display profile image' do
    block = ProfileImageBlock.new

    self.expects(:render).with(template: 'blocks/profile_image', locals: { block: block })
    render_block_content(block)
  end

  should 'be editable' do
    assert ProfileImageBlock.new.editable?
  end
end
