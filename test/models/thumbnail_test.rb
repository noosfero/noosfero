require_relative "../test_helper"

class ThumbnailTest < ActiveSupport::TestCase

  should 'use sensible options' do
    assert_equal :file_system, Thumbnail.attachment_options[:storage]

    Thumbnail.attachment_options[:content_type].each do |item|
      assert_match /(image|application)\/.+/, item
    end
  end

  should 'not allow script files to be uploaded without append .txt in the end' do
    file = Thumbnail.create!(:uploaded_data => fixture_file_upload('files/hello_world.php', 'image/png'))
    assert_equal 'hello_world.php.txt', file.filename
  end
  
end
