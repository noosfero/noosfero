require File.dirname(__FILE__) + '/../test_helper'

class ImageGalleryTest < Test::Unit::TestCase

  should 'be a type of article' do
    assert_kind_of Article, ImageGallery.new
  end

  should 'provide description' do
    ImageGallery.stubs(:==).with(Article).returns(true)
    assert_not_equal Article.description, ImageGallery.description
  end

  should 'provide short description' do
    ImageGallery.stubs(:==).with(Article).returns(true)
    assert_not_equal Article.short_description, ImageGallery.short_description
  end

end
