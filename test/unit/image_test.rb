require File.dirname(__FILE__) + '/../test_helper'

class ImageTest < Test::Unit::TestCase
  fixtures :images

  def setup
    @profile = create_user('testinguser').person
  end
  attr_reader :profile

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

  should 'create thumbnails after processing jobs' do
    file = Image.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :owner => profile)

    process_delayed_job_queue
    Image.attachment_options[:thumbnails].each do |suffix, size|
      assert File.exists?(Image.find(file.id).public_filename(suffix))
    end
    file.destroy
  end

  should 'set thumbnails_processed to true after creating thumbnails' do
    file = Image.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :owner => profile)

    process_delayed_job_queue

    assert Image.find(file.id).thumbnails_processed
    file.destroy
  end

  should 'have thumbnails_processed attribute' do
    assert Image.new.respond_to?(:thumbnails_processed)
  end

  should 'return false by default in thumbnails_processed' do
    assert !Image.new.thumbnails_processed
  end

  should 'set thumbnails_processed to true' do
    file = Image.new
    file.thumbnails_processed = true

    assert file.thumbnails_processed
  end

  should 'have a default image if thumbnails were not processed' do
    file = Image.new
    file.expects(:thumbnailable?).returns(true)
    assert_equal '/images/icons-app/image-loading-thumb.png', file.public_filename(:thumb)
  end

  should 'return image thumbnail if thumbnails were processed' do
    file = Image.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :owner => profile)
    process_delayed_job_queue

    assert_match(/rails_thumb.png/, Image.find(file.id).public_filename(:thumb))

    file.destroy
  end

  should 'store width and height after processing' do
    file = Image.create!(:owner => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    file.create_thumbnails

    file = Image.find(file.id)
    assert_equal [50, 64], [file.width, file.height]
  end

  should 'have a loading image to each size of thumbnails' do
    Image.attachment_options[:thumbnails].each do |suffix, size|
      image = RAILS_ROOT + '/public/images/icons-app/image-loading-%s.png' % suffix
      assert File.exists?(image)
    end
  end

  should 'not create a background job for an image that is already a thumbnail' do
    # this test verifies whether it created background jobs also for the
    # thumbnails!
    assert_no_difference Delayed::Job, :count do
      image = Image.new(:owner => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
      image.stubs(:is_thumbnail?).returns(true)
      image.save!
    end
  end

end
