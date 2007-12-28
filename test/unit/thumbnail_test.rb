require File.dirname(__FILE__) + '/../test_helper'

class ThumbnailTest < Test::Unit::TestCase

  should 'use sensible options' do
    assert_equal :file_system, Thumbnail.attachment_options[:storage]

    Thumbnail.attachment_options[:content_type].each do |item|
      assert_match 'image/', item 
    end
  end
  
end
