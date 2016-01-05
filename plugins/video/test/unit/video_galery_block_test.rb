require File.dirname(__FILE__) + '/../test_helper'
class VideoGaleryBlockTest < ActiveSupport::TestCase

  should "define its description" do
    assert_equal VideoPlugin::VideoGalleryBlock.description, _('Display a Video Gallery')
  end

  should "define its help description" do
    assert_equal VideoPlugin::VideoGalleryBlock.new.help, _('This block presents a video gallery')
  end

end
