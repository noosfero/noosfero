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

  should 'expire cache of articles that use an image that just got a thumbnail' do
    person = create_user('test_user').person
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => person)
    article = create(Article, :name => 'test', :image_builder => {
       :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
    }, :profile_id => person.id)
    old_cache_key = article.cache_key
    job = CreateThumbnailsJob.new(file.class.name, file.id)
    job.perform
    process_delayed_job_queue
    assert_not_equal old_cache_key, Article.find(article.id).reload.cache_key
  end
end
