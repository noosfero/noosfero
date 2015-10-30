require 'test_helper'

class GalleryBlockTest < ActiveSupport::TestCase

  def setup
    @community = fast_create(Community)
  end
  attr_reader :community

  should 'refer to a gallery' do
    gallery = fast_create(Gallery, :profile_id => community.id)
    gallery_block = create(GalleryBlock, :gallery_id => gallery.id)
    gallery_block.stubs(:owner).returns(community)
    assert_equal gallery, gallery_block.gallery
  end

  should 'default interval between transitions is 10 seconds' do
    block = GalleryBlock.new
    assert_equal 10, block.interval
  end

end
