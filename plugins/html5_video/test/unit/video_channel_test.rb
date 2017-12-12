require 'test_helper'

class VideoChannelTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Profile)
    @channel = fast_create(Html5VideoPlugin::VideoChannel,
                           name: 'channel', profile_id: @profile.id)
    @data = fixture_file_upload('videos/atropelamento.ogv', 'video/ogg')
  end

  should 'ignore regular articles inside the video channel' do
    fast_create(Article, profile_id: @profile.id, parent_id: @channel.id)
    assert_equivalent [], @channel.videos.map(&:id)
  end

  should 'return all video files' do
    video1 = UploadedFile.create!(uploaded_data: @data, parent: @channel,
                                  name: 'video1', profile: @profile)
    video2 = UploadedFile.create!(uploaded_data: @data, parent: @channel,
                                  name: 'video2', profile: @profile)
    fast_create(UploadedFile, profile_id: @profile.id, parent_id: @channel.id)

    assert_equivalent [video1.id, video2.id], @channel.videos.map(&:id)
  end

  should 'return non-video files' do
    video1 = UploadedFile.create!(uploaded_data: @data, parent: @channel,
                                  name: 'video1', profile: @profile)
    file = fast_create(UploadedFile, profile_id: @profile.id,
                       parent_id: @channel.id)

    assert_equivalent [file.id], @channel.non_video_files.map(&:id)
  end

  should 'only return converted and unconverted videos' do
    video1 = UploadedFile.create!(uploaded_data: @data, parent: @channel,
                                  name: 'video1', profile: @profile)
    video2 = UploadedFile.create!(uploaded_data: @data, parent: @channel,
                                  name: 'video2', profile: @profile)

    presenter = FilePresenter.for video1
    presenter.web_versions = { OGV: { nice: { status: 'done' } },
                               MP4: { nice: { status: 'done' } },
                               WEBM: { nice: { status: 'done' } } }
    presenter.save!

    assert_equivalent [video1.id], @channel.converted_videos.map(&:id)
    assert_equivalent [video2.id], @channel.unconverted_videos.map(&:id)
  end

end
