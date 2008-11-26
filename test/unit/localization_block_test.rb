require File.dirname(__FILE__) + '/../test_helper'

class LocalizationBlockTest < Test::Unit::TestCase

  def setup
    @profile = create_user('lele').person
    @block = LocalizationBlock.new
    @profile.boxes.first.blocks << @block
    @block.save!
  end
  attr_reader :block, :profile

  should 'provide description' do
    assert_not_equal Block.description, LocalizationBlock.description
  end

  should 'display no localization map without lat' do
    assert_tag_in_string block.content.call, :tag => 'i'
  end

  should 'display localization map' do
    profile.lat = 0
    profile.lng = 0
    profile.save!
    assert_tag_in_string block.content.call, :tag => 'img'
  end

  should 'be editable' do
    assert LocalizationBlock.new.editable?
  end
  
end
