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

  should 'default interval between transitions is 4 seconds' do
    slideshow = SlideshowBlock.new
    assert_equal 4, slideshow.interval
  end

  should 'not invoke javascript when has no gallery' do
    slideshow_block = SlideshowBlock.new()
    assert_nil slideshow_block.footer
  end

  should 'invoke javascript when has gallery' do
    gallery = fast_create(Folder, :profile_id => profile.id)
    slideshow_block = SlideshowBlock.new(:gallery_id => gallery.id)
    assert_not_nil slideshow_block.footer
  end

end
