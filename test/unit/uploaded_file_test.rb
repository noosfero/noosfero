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
    f = fast_create(Folder, :name => 'test_folder', :profile_id => p.id)
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

  should 'match max_size in validates message of size field' do
    up = UploadedFile.new(:filename => 'fake_filename.png')
    up.valid?

    assert_match /#{UploadedFile.max_size.to_humanreadable}/, up.errors[:size]
  end

  should 'display link to download of non-image files' do
    p = create_user('test_user').person
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'), :profile => p)

    stubs(:content_tag).returns('link')
    expects(:link_to).with(file.name, file.url, :class => file.css_class_name)

    instance_eval(&file.to_html)
  end

  should 'have title' do
    assert_equal 'my title', UploadedFile.new(:title => 'my title').title
  end

  should 'limit title to 140 characters' do
    upload = UploadedFile.new

    upload.title = '+' * 61; upload.valid?
    assert upload.errors[:title]

    upload.title = '+' * 60; upload.valid?
    assert !upload.errors[:title]

  end

  should 'always provide a display title' do
    upload = UploadedFile.new(:uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))
    assert_equal 'test.txt',  upload.display_title
    upload.title = 'My text file'
    assert_equal 'My text file', upload.display_title
    upload.title = ''
    assert_equal 'test.txt', upload.display_title
  end

  should 'use name as title by default' do
    upload = UploadedFile.new
    upload.stubs(:name).returns('test.txt')

    assert_equal 'test.txt', upload.title
  end

end
