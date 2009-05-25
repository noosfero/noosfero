require File.dirname(__FILE__) + '/../test_helper'

class ProfileImageBlockTest < Test::Unit::TestCase

  should 'provide description' do
    assert_not_equal Block.description, ProfileImageBlock.description
  end

  should 'display profile image' do
    block = ProfileImageBlock.new

    self.expects(:render).with(:file => 'blocks/profile_image', :locals => { :block => block, :show_name => false})
    instance_eval(& block.content)
  end

  should 'not be editable' do
    assert ProfileImageBlock.new.editable?
  end

end
