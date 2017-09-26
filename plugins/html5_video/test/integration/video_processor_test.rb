require 'test_helper'
require_relative '../download_fixture'
require_relative '../../script/video_processor_foreground'
require_relative '../html5_video_plugin_test_helper'

class VideoProcessorTest < ActiveSupport::TestCase

  prepend Html5VideoPluginTestHelper

  # Disable transactional fixtures, so rails runner can see the same data
  self.use_transactional_fixtures = false

  def setup
    file = fixture_file_upload('/videos/atropelamento.ogv', 'video/ogv')
    profile = fast_create(Person)
    @video = UploadedFile.create!(uploaded_data: file, profile: profile)
    @presenter = FilePresenter.for @video
  end

  should 'save preview images and web versions for a video' do
    refute @presenter.has_previews?
    assert @presenter.web_versions.blank?

    process_video(@video.environment_id, @video.full_filename, @video.id)
    @presenter.reload

    web_versions = @presenter.web_versions!
    assert @presenter.has_previews?
    all_versions.each do |format, size|
      assert_equal 'done', web_versions[format][size][:status]
    end
    assert web_versions[:OGV][:orig].present?
  end

  should 'save errors when processing a file that does not exist' do
    process_video(@video.environment_id, 'not/a/file', @video.id)
    @presenter.reload

    assert_equal :fail, @presenter.previews
    all_versions.each do |format, size|
      assert_equal 'error reading',
                   @presenter.web_versions[format][size][:status]
    end
  end

  should 'save errors when ffmpeg fails to convert the videos' do
    VideoProcessor::Ffmpeg.any_instance.stubs(:make_webm_for_web).returns({
      error: { code: 1, message: 'Ops' },
      conf: {}
    })
    process_video(@video.environment_id, @video.full_filename, @video.id)
    @presenter.reload

    assert @presenter.has_previews?
    @presenter.web_versions[:WEBM].each do |size, version|
      assert_equal 'error converting', version[:status]
    end
    @presenter.web_versions[:OGV].each do |size, version|
      assert_equal 'done', version[:status]
    end
  end

  private

  def all_versions
    [:OGV, :WEBM].product([:tiny, :nice])
  end

end
