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

  should 'can display hits' do
    file = UploadedFile.new(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    assert_equal false, file.can_display_hits?
  end

  should 'not upload files bigger than max_size' do
    f = UploadedFile.new(:profile => @profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    f.expects(:size).returns(UploadedFile.attachment_options[:max_size] + 1024)
    assert !f.valid?
  end

  should 'upload files smaller than max_size' do
    f = UploadedFile.new(:profile => @profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    f.expects(:size).returns(UploadedFile.attachment_options[:max_size] - 1024)
    assert f.valid?
  end

  should 'create icon when created in folder' do
    p = create_user('test_user').person
    f = Folder.create!(:name => 'test_folder', :profile => p)
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent_id => f.id, :profile => p)

    assert File.exists?(file.public_filename(:icon))
    file.destroy
  end

  should 'create icon when not created in folder' do
    p = create_user('test_user').person
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => p)

    assert File.exists?(file.public_filename(:icon))
    file.destroy
  end

  should 'resize images bigger than in resize_to' do
    fixture_filename = '/files/test-large-pic.jpg'
    filename = RAILS_ROOT + '/test/fixtures' + fixture_filename
    system('echo "image for test" | convert -background yellow -page 1280x960 text:- %s' % filename)

    f = UploadedFile.create(:profile => @profile, :uploaded_data => fixture_file_upload(fixture_filename, 'image/jpg'))

    assert_equal [640, 480], [f.width, f.height]

    File.rm_f(filename)
  end

  should 'resize images on folder bigger than in resize_to' do
    fixture_filename = '/files/test-large-pic.jpg'
    filename = RAILS_ROOT + '/test/fixtures' + fixture_filename
    system('echo "image for test" | convert -background yellow -page 1280x960 text:- %s' % filename)
    f = Folder.create!(:name => 'test_folder', :profile => @profile)

    file = UploadedFile.create(:profile => @profile, :uploaded_data => fixture_file_upload(fixture_filename, 'image/jpg'), :parent_id => f.id)

    assert_equal [640, 480], [file.width, file.height]

    File.rm_f(filename)
  end

end
