require_relative "../test_helper"
require 'boxes_helper'

class SlideshowBlockTest < ActiveSupport::TestCase
  include BoxesHelper

  def setup
    @profile = fast_create(Profile)
  end
  attr_reader :profile

  should 'refer to a gallery' do
    gallery = fast_create(Gallery, :profile_id => profile.id)
    slideshow_block = create(SlideshowBlock, :gallery_id => gallery.id)
    assert_equal gallery, slideshow_block.gallery
  end

  should 'not crash if referencing unexisting folder' do
    assert_nil build(SlideshowBlock, :gallery_id => -999).gallery
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
    render_block_content(block)
  end

  should 'list in random order' do
    gallery = mock
    images = []
    shuffled = []
    block = build(SlideshowBlock, :shuffle => true)
    block.stubs(:gallery).returns(gallery)
    block.stubs(:block_images).returns(images)
    images.expects(:shuffle).once.returns(shuffled)

    render_block_content(block)
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

  should 'display "thumb" size by default' do
    assert_equal 'thumb', SlideshowBlock.new.image_size
  end

  should 'set different image size' do
    block = build(SlideshowBlock, :image_size => 'slideshow')
    assert_equal 'slideshow', block.image_size
  end

  should 'decide correct public filename for image' do
    image = mock
    image.expects(:public_filename).with('slideshow').returns('/bli/slideshow.png')
    File.expects(:exists?).with(Rails.root.join('public', 'bli', 'slideshow.png').to_s).returns(true)

    assert_equal '/bli/slideshow.png', build(SlideshowBlock, :image_size => 'slideshow').public_filename_for(image)
  end

  should 'display the default slideshow image if thumbnails were not processed' do
    image = mock
    image.expects(:public_filename).with('slideshow').returns('/images/icons-app/image-loading-slideshow.png')
    File.expects(:exists?).with(Rails.root.join('public', 'images', 'icons-app', 'image-loading-slideshow.png').to_s).returns(true)

    assert_equal '/images/icons-app/image-loading-slideshow.png', build(SlideshowBlock, :image_size => 'slideshow').public_filename_for(image)
  end

  should 'fallback to existing size in case the requested size does not exist' do
    block = build(SlideshowBlock, :image_size => 'slideshow')

    image = mock
    # "slideshow" size does not exist
    image.expects(:public_filename).with('slideshow').returns('/bli/slideshow.png')
    File.expects(:exists?).with(Rails.root.join('public', 'bli', 'slideshow.png').to_s).returns(false) # <<<<<

    # thumb size does exist
    image.expects(:public_filename).with('thumb').returns('/bli/thumb.png')
    File.expects(:exists?).with(Rails.root.join('public', 'bli', 'thumb.png').to_s).returns(true) # <<<<<

    assert_equal '/bli/thumb.png', block.public_filename_for(image)
  end

  should 'choose between owner image galleries' do
    block = SlideshowBlock.new
    owner = mock
    block.stubs(:owner).returns(owner)

    list = []
    owner.expects(:image_galleries).returns(list)
    assert_same list, block.folder_choices
  end

end
