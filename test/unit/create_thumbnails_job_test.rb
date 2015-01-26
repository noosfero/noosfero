require_relative "../test_helper"

class CreateThumbnailsJobTest < ActiveSupport::TestCase

  should 'create thumbnails to uploaded files' do
    person = create_user('test_user').person
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => person)

    assert_equal [], file.thumbnails
    job = CreateThumbnailsJob.new(file.class.name, file.id)
    job.perform
    file.reload
    assert_not_equal [], file.thumbnails
  end

  should 'set thumbnails_processed to true after finished' do
    person = create_user('test_user').person
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => person)

    job = CreateThumbnailsJob.new(file.class.name, file.id)
    job.perform

    file.reload
    assert file.thumbnails_processed
  end

  should 'not create thumbnails from deleted files' do
    person = create_user('test_user').person
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => person)
    job = CreateThumbnailsJob.new(file.class.name, file.id)
    file.destroy
    assert_nothing_raised do
      job.perform
    end
  end

end
