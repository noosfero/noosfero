require File.dirname(__FILE__) + '/../test_helper'

class ImageGalleryTest < Test::Unit::TestCase

  should 'be a type of article' do
    assert_kind_of Article, ImageGallery.new
  end

  should 'provide description' do
    assert_kind_of String, ImageGallery.description
  end

  should 'provide short description' do
    assert_kind_of String, ImageGallery.short_description
  end

end
