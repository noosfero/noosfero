require File.dirname(__FILE__) + '/../test_helper'

class LocationBlockTest < ActiveSupport::TestCase

  def setup
    @profile = create_user('lele').person
    @block = LocationBlock.new
    @profile.boxes.first.blocks << @block
    @block.save!
  end
  attr_reader :block, :profile

  should 'provide description' do
    assert_not_equal Block.description, LocationBlock.description
  end

  should 'display no localization map without lat' do
    assert_tag_in_string block.content, :tag => 'i'
  end

  should 'display localization map' do
    profile.lat = 0
    profile.lng = 0
    profile.save!
    assert_tag_in_string block.content, :tag => 'img'
  end

  should 'be editable' do
    assert LocationBlock.new.editable?
  end
  
  should 'default title be blank by default' do
    assert_equal '', LocationBlock.new.title
  end

end
