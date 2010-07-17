require File.dirname(__FILE__) + '/../test_helper'

class ImageTest < ActiveSupport::TestCase
  fixtures :images

  should 'have thumbnails options' do
    [:big, :thumb, :portrait, :minor, :icon].each do |option|
      assert Image.attachment_options[:thumbnails].include?(option), "should have #{option}"
    end
  end

  should 'match max_size in validates message of size field' do
    image = Image.new(:filename => 'fake_filename.png')
    image.valid?

    assert_match /#{Image.max_size.to_humanreadable}/, image.errors[:size]
  end

end
