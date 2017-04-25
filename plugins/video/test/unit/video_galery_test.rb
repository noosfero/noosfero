require_relative '../test_helper'

class VideoGaleryTest < ActiveSupport::TestCase

  should "define its type_name as Video Gallery" do
    assert_equal VideoPlugin::VideoGallery.type_name, _('Video Gallery')
  end

  should "define its short_description" do
    assert_equal VideoPlugin::VideoGallery.short_description, _('Video Gallery')
  end

  should "define its description" do
    assert_equal VideoPlugin::VideoGallery.description, _('A gallery of link to videos that are hosted elsewhere.')
  end

  should 'render nothing with an empty gallery message when there are no children' do
    video_gallery = VideoPlugin::VideoGallery.new
    video_gallery.children = []
    video_gallery.stubs(:body).returns('Video gallery body')

    content = instance_eval(&video_gallery.to_html)
    assert_tag_in_string content, tag: 'em', content: _('(empty video gallery)')
  end

  should 'render the body and a empty gallery message when there are no children' do
    body = "Video Gallery Body"
    video_gallery = VideoPlugin::VideoGallery.new
    video_gallery.children = []
    video_gallery.expects(:body).twice.returns(body)

    content = instance_eval(&video_gallery.to_html)

    assert_match body, content
    assert_tag_in_string content, tag: 'em', content: _('(empty video gallery)')
  end

end
