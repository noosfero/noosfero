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

require 'boxes_helper'

class GalleryBlockViewTest < ActionView::TestCase
  include BoxesHelper

  def setup
    @community = fast_create(Community)
  end

  should 'display the default message for empty gallery' do
    block = GalleryBlock.new
    block.stubs(:owner).returns(@community)

    ActionView::Base.any_instance.expects(:block_title).returns("")

    content = render_block_content(block)

    assert_match /#{_('Please, edit this block and choose some gallery')}/, content
  end

  should "display the gallery's content" do
    gallery = fast_create(Gallery, :profile_id => @community.id)
    image = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => gallery, :profile => @community)
    block = create(GalleryBlock, :gallery_id => gallery.id)
    block.stubs(:owner).returns(@community)

    ActionView::Base.any_instance.expects(:block_title).returns("")

    content = render_block_content(block)

    assert_tag_in_string content, tag: 'img', attributes: {src: image.public_filename(:thumb)}
    assert_tag_in_string content, tag: 'span', content: _('Next')
  end
end
