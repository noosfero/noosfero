require_relative "../test_helper"

class LocationBlockTest < ActiveSupport::TestCase

  ActionView::Base.send :include, BlockHelper
  include BoxesHelper

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
    assert_tag_in_string extract_block_content(render_block_content(block)), :tag => 'i'
  end

  should 'be editable' do
    assert LocationBlock.new.editable?
  end

  should 'default title be blank by default' do
    assert_equal '', LocationBlock.new.title
  end

  should 'use google maps api v3 with ssl' do
    @block.owner.lat = '-12.34'; @block.owner.save!
    content = extract_block_content(render_block_content(@block))

    assert_match 'https://maps.google.com/maps/api/staticmap', content
    assert_no_match /key=/, content
  end

end
