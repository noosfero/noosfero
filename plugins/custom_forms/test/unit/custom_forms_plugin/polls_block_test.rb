require 'test_helper'

class CustomFormsPlugin::PollsBlockTest < ActiveSupport::TestCase

  should 'validate status with status options' do
    block = CustomFormsPlugin::PollsBlock.new()

    block.metadata['status'] = 'invalid_status'
    block.valid?
    assert block.errors.include?(:metadata)

    block.metadata['status'] = 'all'
    block.valid?
    refute block.errors.include?(:metadata)
  end

end

