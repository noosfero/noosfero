require_relative "../test_helper"

class UploadedFileTest < ActiveSupport::TestCase

  def setup
    User.current = user = create_user 'testinguser'
    @profile = user.person
  end
  attr_reader :profile

  should 'return a default icon for uploaded files' do
    assert_equal 'upload-file', UploadedFile.icon_name
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

  should 'not set filename on name if name is already set' do
    file = UploadedFile.new
    file.name = "Some name"
    file.filename = 'test.txt'
    assert_equal 'Some name', file.name
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
    file = build(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    file.profile = profile
    assert file.save
    assert file.is_image
  end

  should 'has attachment_fu validation options' do
    file = build(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    assert_respond_to file, :attachment_validation_options
  end

  should 'has attachment_fu validation option for size' do
    file = build(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    assert_includes file.attachment_validation_options, :size
  end

  should 'can display hits' do
    file = build(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    assert_equal false, file.can_display_hits?
  end

  should 'not upload files bigger than max_size' do
    f = build(UploadedFile, :profile => @profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    f.expects(:size).returns(UploadedFile.attachment_options[:max_size] + 1024)
    refute f.valid?
  end

  should 'upload files smaller than max_size' do
    f = build(UploadedFile, :profile => @profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    f.expects(:size).returns(UploadedFile.attachment_options[:max_size] - 1024)
    assert f.valid?
  end

  should 'create icon when created in folder' do
    p = create_user('test_user').person
    f = fast_create(Folder, :name => 'test_folder', :profile_id => p.id)
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent_id => f.id, :profile => p)

    process_delayed_job_queue

    file.reload
    assert File.exists?(file.public_filename(:icon))
    file.destroy
  end

  should 'create icon when not created in folder' do
    p = create_user('test_user').person
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => p)

    process_delayed_job_queue
    assert File.exists?(UploadedFile.find(file.id).public_filename(:icon))
    file.destroy
  end

  should 'match max_size in validates message of size field' do
    up = build(UploadedFile, :filename => 'fake_filename.png')
    up.valid?

    assert_match /#{UploadedFile.max_size.to_humanreadable}/, up.errors[:size].first
  end

  should 'display link to download of non-image files' do
    p = create_user('test_user').person
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'), :profile => p)

    ENV.stubs('[]').with('RAILS_ENV').returns('other')
    Rails.logger.expects(:warn) # warn about deprecatede usage of UploadedFile#to_html
    stubs(:puts)
    stubs(:content_tag).returns('link')
    expects(:link_to).with(file.name, file.url)

    instance_eval(&file.to_html)
  end

  should 'have title' do
    assert_equal 'my title', build(UploadedFile, :title => 'my title').title
  end

  should 'always provide a display title' do
    upload = UploadedFile.new(:uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))
    assert_equal 'test.txt',  upload.title
    upload.title = 'My text file'
    assert_equal 'My text file', upload.title
    upload.title = ''
    assert_equal 'test.txt', upload.title
  end

  should 'use name as title by default' do
    upload = UploadedFile.new
    upload.stubs(:name).returns('test.txt')

    assert_equal 'test.txt', upload.title
  end

  should 'use name as title by default but cut down the title' do
    upload = build(UploadedFile, :uploaded_data => fixture_file_upload('/files/AGENDA_CULTURA_-_FESTA_DE_VAQUEIROS_PONTO_DE_SERRA_PRETA_BAIXA.txt'))
    upload.valid?
    assert upload.errors[:title].blank?
  end

  should 'create thumbnails after processing jobs' do
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => profile)

    process_delayed_job_queue

    UploadedFile.attachment_options[:thumbnails].each do |suffix, size|
      assert File.exists?(UploadedFile.find(file.id).public_filename(suffix))
    end
    file.destroy
  end

  should 'set thumbnails_processed to true after creating thumbnails' do
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => profile)

    process_delayed_job_queue

    assert UploadedFile.find(file.id).thumbnails_processed
    file.destroy
  end

  should 'have thumbnails_processed attribute' do
    assert UploadedFile.new.respond_to?(:thumbnails_processed)
  end

  should 'return false by default in thumbnails_processed' do
    refute UploadedFile.new.thumbnails_processed
  end

  should 'set thumbnails_processed to true' do
    file = UploadedFile.new
    file.thumbnails_processed = true

    assert file.thumbnails_processed
  end

  should 'have a default image if thumbnails were not processed' do
    file = UploadedFile.new
    file.expects(:thumbnailable?).returns(true)
    assert_equal '/images/icons-app/image-loading-thumb.png', file.public_filename
  end

  should 'return image thumbnail if thumbnails were processed' do
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => profile)
    process_delayed_job_queue

    assert_match(/rails_thumb.png/, UploadedFile.find(file.id).public_filename(:thumb))

    file.destroy
  end

  should 'store width and height after processing' do
    file = create(UploadedFile, :profile => @profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    file.create_thumbnails

    file = UploadedFile.find(file.id)
    assert_equal [50, 64], [file.width, file.height]
  end

  should 'have a loading image to each size of thumbnails' do
    UploadedFile.attachment_options[:thumbnails].each do |suffix, size|
      image = Rails.root.join('public', 'images', 'icons-app', "image-loading-#{suffix}.png")
      assert File.exists?(image)
    end
  end

  should 'return a thumbnail for images' do
    f = UploadedFile.new
    f.expects(:image?).returns(true)
    f.expects(:full_filename).with(:display).returns(Rails.root.join('public', 'images', '0000', '0005', 'x.png'))
    assert_equal '/images/0000/0005/x.png', f.thumbnail_path
    f = UploadedFile.new
    f.stubs(:full_filename).with(:display).returns(Rails.root.join('public', 'images', '0000', '0005', 'x.png'))
    f.expects(:image?).returns(false)
    assert_nil f.thumbnail_path
  end

  should 'track action when a published image is uploaded in a gallery' do
    p = fast_create(Gallery, :profile_id => @profile.id)
    f = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => p, :profile => @profile)
    ta = ActionTracker::Record.where(verb: "upload_image").last
    assert_kind_of String, ta.get_thumbnail_path[0]
    assert_equal [f.reload.view_url], ta.get_view_url
    assert_equal [p.reload.url], ta.get_parent_url
    assert_equal [p.name], ta.get_parent_name
  end

  should 'not track action when is not image' do
    ActionTracker::Record.delete_all
    p = fast_create(Gallery, :profile_id => @profile.id)
    f = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'), :parent => p, :profile => @profile)
    assert_nil ActionTracker::Record.where(verb: "upload_image").last
  end

  should 'not track action when has no parent' do
    f = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => nil, :profile => @profile)
    assert_nil ActionTracker::Record.where(verb: "upload_image").last
  end

  should 'not track action when is not published' do
    ActionTracker::Record.delete_all
    p = fast_create(Gallery, :profile_id => @profile.id)
    f = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => p, :profile => @profile, :published => false)
    assert_nil ActionTracker::Record.where(verb: "upload_image").last
  end

  should 'not track action when parent is not gallery' do
    ActionTracker::Record.delete_all
    p = fast_create(Folder, :profile_id => @profile.id)
    f = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => p, :profile => @profile)
    assert_nil ActionTracker::Record.where(verb: "upload_image").last
  end

  should 'not crash if first paragraph called' do
    f = fast_create(UploadedFile)
    assert_nothing_raised do
      f.first_paragraph
    end
  end

  should 'return empty string to lead if no abstract given' do
    f = fast_create(UploadedFile, :abstract => nil)
    assert_equal '', f.lead
  end

  should 'upload to a folder with same name as the schema if database is postgresql' do
    uses_postgresql 'image_schema_one'
    file1 = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => @profile)
    process_delayed_job_queue
    assert_match(/image_schema_one\/\d{4}\/\d{4}\/rails.png/, UploadedFile.find(file1.id).public_filename)
    uses_postgresql 'image_schema_two'
    file2 = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'), :profile => @profile)
    assert_match(/image_schema_two\/\d{4}\/\d{4}\/test.txt/, UploadedFile.find(file2.id).public_filename)
    file1.destroy
    file2.destroy
    uses_sqlite
  end

  should 'return extension' do
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => @profile)
    assert_equal 'png', file.extension
  end

  should 'upload to path prefix folder if database is not postgresql' do
    uses_sqlite
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'), :profile => @profile)
    assert_match(/\/\d{4}\/\d{4}\/test.txt/, UploadedFile.find(file.id).public_filename)
    assert_no_match(/test_schema\/\d{4}\/\d{4}\/test.txt/, UploadedFile.find(file.id).public_filename)
    file.destroy
  end

  should 'upload thumbnails to a folder with same name as the schema if database is postgresql' do
    uses_postgresql
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => @profile)
    process_delayed_job_queue
    UploadedFile.attachment_options[:thumbnails].each do |suffix, size|
      assert_match(/test_schema\/\d{4}\/\d{4}\/rails_#{suffix}.png/, UploadedFile.find(file.id).public_filename(suffix))
    end
    file.destroy
    uses_sqlite
  end

  should 'not allow script files to be uploaded without append .txt in the end' do
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('files/hello_world.php', 'application/x-php'), :profile => @profile)
    assert_equal 'hello_world.php.txt', file.filename
  end

  should 'use gallery as target for action tracker' do
    gallery = fast_create(Gallery, :profile_id => profile.id)
    image = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => gallery, :profile => profile)
    activity = ActionTracker::Record.find_last_by_verb 'upload_image'
    assert_equal gallery, activity.target
  end

  should 'group trackers activity of image\'s upload' do
    ActionTracker::Record.delete_all
    gallery = fast_create(Gallery, :profile_id => profile.id)

    image1 = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => gallery, :profile => profile)
    assert_equal 1, ActionTracker::Record.find_all_by_verb('upload_image').count

    image2 = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/other-pic.jpg', 'image/jpg'), :parent => gallery, :profile => profile)
    assert_equal 1, ActionTracker::Record.find_all_by_verb('upload_image').count
  end

  {
    nil       => 5.megabytes,   # default
    '1KB'     => 1.kilobytes,
    '2MB'     => 2.megabyte,
    '3GB'     => 3.gigabytes,
    '4TB'     => 4.terabytes,
    '6 MB'    => 6.megabytes,   # allow whitespace between number and unit
    '0.5 GB'  => 512.megabytes, # allow floating point numbers
    '2'       => 2.megabytes,   # assume MB as unit by default
    'INVALID' => 5.megabytes,   # use default for invalid input
    '1ZYX'    => 5.megabytes,   # use default for invalid input
  }.each do |input,output|
    should 'maximum upload size: convert %s into %s' % [input, output] do
      NOOSFERO_CONF.expects(:[]).with('max_upload_size').returns(input)
      assert_equal output, UploadedFile.max_size
    end
  end
  should 'max_size should always return an integer' do
    NOOSFERO_CONF.expects(:[]).with('max_upload_size').returns("0.5 GB").at_least_once
    assert_instance_of Fixnum, UploadedFile.max_size
  end

end
