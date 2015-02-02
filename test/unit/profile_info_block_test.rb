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

  should 'display profile information' do
    self.expects(:render).with(:file => 'blocks/profile_info', :locals => { :block => block})
    instance_eval(& block.content)
  end

end
