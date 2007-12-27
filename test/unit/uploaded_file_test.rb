require File.dirname(__FILE__) + '/../test_helper'

class UploadedFileTest < Test::Unit::TestCase

  should 'return a thumbnail as icon' do
    f = UploadedFile.new
    f.expects(:public_filename).with(:icon).returns('/path/to/file.xyz')
    assert_equal '/path/to/file.xyz', f.icon_name
  end
  
end
