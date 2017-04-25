require 'test_helper'
require_relative '../download_fixture'

class CreateVideoPreviewJobTest < ActiveSupport::TestCase

  def setup
    Environment.default.enable_plugin Html5VideoPlugin
  end

  def run_CreateVideoPreviewJob_for_video(video)
    jobs = video.web_preview_jobs
    # Run all CreateVideoPreviewJob's for this created video:
    print '['; STDOUT.flush
    jobs.each do |job|
      YAML.load(job.handler).perform
      STDOUT.write '+'; STDOUT.flush # a progress to the user see something.
    end
    print ']'; STDOUT.flush
    video.reload
  end

  should 'create preview images to uploaded videos' do

    video = FilePresenter.for UploadedFile.create!(
      :uploaded_data => fixture_file_upload('/videos/firebus.3gp', 'video/3gpp'),
      :profile => fast_create(Person) )
    assert not(video.has_previews?)

    run_CreateVideoPreviewJob_for_video video
    video.reload

    assert video.has_previews?, 'must have built preview images'
    assert_equal({:big   => '/web/preview_160x120.jpg',
                  :thumb => '/web/preview_107x80.jpg'},
                  video.previews)

    video_path = File.dirname(video.full_filename)

    assert File.exist?(video_path + video.previews[:big])
    assert File.exist?(video_path + video.previews[:thumb])
    assert_match /^\/[^ ]*\/[0-9]+\/+web\/preview_160x120.jpg JPEG 160x720 /, `identify #{video_path + video.previews[:big]}`
    assert_match /^\/[^ ]*\/[0-9]+\/+web\/preview_107x80.jpg JPEG 107x480 /, `identify #{video_path + video.previews[:thumb]}`

  end

end
