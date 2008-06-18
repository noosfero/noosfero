require File.dirname(__FILE__) + '/../test_helper'

class UploadedFileTest < Test::Unit::TestCase

  def setup
    @profile = create_user('testinguser').person
  end
  attr_reader :profile

  should 'return a thumbnail as icon for images ' do
    f = UploadedFile.new
    f.expects(:image?).returns(true)
    f.expects(:public_filename).with(:icon).returns('/path/to/file.xyz')
    assert_equal '/path/to/file.xyz', f.icon_name
  end

  should 'return mime-type icon for non-image files' do
    f= UploadedFile.new
    f.expects(:image?).returns(false)
    f.expects(:content_type).returns('application/pdf')
    assert_equal 'application-pdf', f.icon_name
  end

  should 'use attachment_fu content_type method to return mime_type' do
    f = UploadedFile.new
    f.expects(:content_type).returns('application/pdf')
    assert_equal 'application/pdf', f.mime_type
  end 

  should 'provide proper description' do
    assert_kind_of String, UploadedFile.description
  end

  should 'provide proper short description' do
    assert_kind_of String, UploadedFile.short_description
  end

  should 'set name from uploaded filename' do
    file = UploadedFile.new
    file.filename = 'test.txt'
    assert_equal 'test.txt', file.name
  end

  should 'provide file content as data' do
    file = UploadedFile.new
    file.expects(:full_filename).returns('myfilename')
    File.expects(:read).with('myfilename').returns('my data')
    assert_equal 'my data', file.data
  end

  should 'not allow child articles' do
    assert_equal false, UploadedFile.new.allow_children?
  end

  should 'properly save images' do
    file = UploadedFile.new(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    file.profile = profile
    assert file.save
  end

  should 'has attachment_fu validation options' do
    file = UploadedFile.new(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    assert_respond_to file, :attachment_validation_options
  end

  should 'has attachment_fu validation option for size' do
    file = UploadedFile.new(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    assert_includes file.attachment_validation_options, :size
  end

end
