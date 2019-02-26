require_relative "../test_helper"

class ProfileInfoBlockTest < ActiveSupport::TestCase

  def setup
    @profile = create_user('mytestuser').person

    @block = ProfileInfoBlock.new
    @profile.boxes.first.blocks << @block

    @block.save!
  end
  attr_reader :block, :profile

  should 'provide description' do
    assert_not_equal Block.description, ProfileInfoBlock.description
  end

  include BoxesHelper

  should 'display profile information' do
    self.expects(:render).with(template: 'blocks/profile_info', locals: { block: block })
    render_block_content(block)
  end

end
