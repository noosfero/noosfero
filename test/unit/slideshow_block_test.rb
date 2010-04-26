require File.dirname(__FILE__) + '/../test_helper'

class SlideshowBlockTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Profile)
  end
  attr_reader :profile

  should 'refer to a gallery' do
    gallery = fast_create(Folder, :profile_id => profile.id)
    gallery.view_as = 'image_gallery'
    gallery.save!
    slideshow_block = SlideshowBlock.create!(:gallery_id => gallery.id)
    assert_equal gallery, slideshow_block.gallery
  end

  should 'not crash if referencing unexisting folder' do
    assert_nil SlideshowBlock.new(:gallery_id => -999).gallery
  end

  should 'default interval between transitions is 4 seconds' do
    slideshow = SlideshowBlock.new
    assert_equal 4, slideshow.interval
  end

  should 'list in the same order' do
    gallery = mock
    images = []
    images.expects(:shuffle).never
    gallery.stubs(:images).returns(images)

    block = SlideshowBlock.new
    block.stubs(:gallery).returns(gallery)
    block.content
  end

  should 'list in random order' do
    gallery = mock
    images = []
    shuffled = []
    block = SlideshowBlock.new(:shuffle => true)
    block.stubs(:gallery).returns(gallery)
    block.stubs(:block_images).returns(images)
    images.expects(:shuffle).once.returns(shuffled)

    block.content
  end

  should 'not shuffle by default' do
    assert_equal false, SlideshowBlock.new.shuffle
  end

  should 'not display navigation by default' do
    assert_equal false, SlideshowBlock.new.navigation
  end

  should 'not show folders' do
    folder = fast_create(Folder, :profile_id => profile.id)
    gallery = fast_create(Folder, :profile_id => profile.id)
    gallery.children << folder
    block = SlideshowBlock.new
    block.stubs(:gallery).returns(gallery)

    assert_not_includes block.block_images, folder
  end

end
