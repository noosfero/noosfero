require File.dirname(__FILE__) + '/../test_helper'
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

end
