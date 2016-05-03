require File.dirname(__FILE__) + '/../test_helper'
class VideoGaleryBlockTest < ActiveSupport::TestCase

  should "define its description" do
    assert_equal VideoPlugin::VideoGalleryBlock.description, _('Display a Video Gallery')
  end

  should "define its help description" do
    assert_equal VideoPlugin::VideoGalleryBlock.new.help, _('This block presents a video gallery')
  end

end

require 'boxes_helper'

class VideoGalleryBlockViewTest < ActionView::TestCase
  include BoxesHelper

  should 'render nothing without a video_gallery_id' do
    block = VideoPlugin::VideoGalleryBlock.new

    content = render_block_content(block)

    assert_equal content, "\n"
  end

  should 'render nothing with an empty gallery message when there are no children' do
    block = VideoPlugin::VideoGalleryBlock.new
    block.video_gallery_id = 42

    body = ""
    video_gallery = VideoPlugin::VideoGallery.new
    video_gallery.children = []
    video_gallery.expects(:body).returns(body)
    VideoPlugin::VideoGallery.expects(:find).with(block.video_gallery_id).returns(video_gallery)

    content = render_block_content(block)

    assert_tag_in_string content, tag: 'em', content: _('(empty video gallery)')
  end

  should 'render the body and a empty gallery message when there are no children' do
    block = VideoPlugin::VideoGalleryBlock.new
    block.video_gallery_id = 42

    body = "Video Gallery Body"
    video_gallery = VideoPlugin::VideoGallery.new
    video_gallery.children = []
    video_gallery.expects(:body).twice.returns(body)
    VideoPlugin::VideoGallery.expects(:find).with(block.video_gallery_id).returns(video_gallery)

    content = render_block_content(block)

    assert_tag_in_string content, tag: 'div', content: "\n      #{body}\n    "
    assert_tag_in_string content, tag: 'em', content: _('(empty video gallery)')
  end
end
