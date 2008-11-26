require File.dirname(__FILE__) + '/../test_helper'

class ImageTest < Test::Unit::TestCase
  fixtures :images

  should 'have thumbnails options' do
    [:big, :thumb, :portrait, :minor, :icon].each do |option|
      assert Image.attachment_options[:thumbnails].include?(option), "should have #{option}"
    end
  end

end
