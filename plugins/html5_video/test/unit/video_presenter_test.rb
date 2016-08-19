require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../download_fixture'
$LOAD_PATH << File.dirname(__FILE__) + '/../../lib/'
require 'html5_video_plugin.rb'

class VideoPresenterTest < ActiveSupport::TestCase

  #include Html5VideoPlugin::Ffmpeg

  def create_video(file, mime)
    file = UploadedFile.create!(
      :uploaded_data => fixture_file_upload('/videos/'+file, mime),
      :profile => fast_create(Person))
  end

  def process_video(file)
    process_delayed_job_queue
    file.reload
    FilePresenter::Video.new file
  end

  def create_and_proc_video(file, mime)
    process_video(create_video(file, mime))
  end

  def setup
    Environment.default.enable_plugin Html5VideoPlugin
  end

  should 'accept to encapsulate a video file' do
    file = create_video 'old-movie.mpg', 'video/mpeg'
    assert_equal 10, FilePresenter::Video.accepts?(file)
  end

  should 'retrieve meta-data' do
    video = create_and_proc_video('old-movie.mpg', 'video/mpeg')
    assert_equal 'Video (MPEG)', video.short_description, 'describe the file type'
    assert_equivalent video.meta_data.settings.keys,
      [:image_previews, :original_video, :web_versions]
    assert_equivalent video.original_video.keys,
      [:metadata, :type, :streams, :global_bitrate, :error, :duration, :parameters]
    assert_equal h2s([:OGV, :WEBM]), h2s(video.web_versions.keys)
  end

  should 'retrieve all web versions' do
    video1 = create_and_proc_video('old-movie.mpg', 'video/mpeg')
    video2 = create_and_proc_video('atropelamento.ogv', 'video/ogg')
    # make video2 as fake valid web video:
    audio = video2.original_video[:streams].find{|s| s[:type] == 'audio' }
    audio = audio[:codec] = 'vorbis'
    assert_equal video1.web_versions, video1.web_versions!, 'all web versions (1)'
    assert_equal h2s(video2.web_versions[:OGV].merge(:orig => {
      :type => :OGV,
      :status => "done",
      :vbrate => 334,
      :size_name => "orig",
      :file_name => "atropelamento.ogv",
      :size => {:h=>130, :w=>208},
      :original => true,
      :path => video2.public_filename,
      :abrate => 0 })),
      h2s(video2.web_versions![:OGV]), 'all web versions (2)'
    # test get the tiniest web version:
    data = video1.tiniest_web_version(:OGV)
    assert_equal h2s(data), h2s(
      :type=>:OGV, :size_name=>"tiny", :status=>"done",
      :fps=>12, :abrate=>64, :vbrate=>250, :size=>{:h=>212, :w=>320},
      :path=>File.join(Rails.root,"/test/tmp/0000/#{'%04d'%video1.id}/web/tiny.ogv"),
      :file_name=>"tiny.ogv" )
  end

  should 'know if it has ready_web_versions' do
    file = create_video 'old-movie.mpg', 'video/mpeg'
    video = FilePresenter::Video.new file
    assert_equal h2s(video.ready_web_versions), h2s({})
    video = process_video file
    web_versions = video.ready_web_versions
    assert_equal 'nice.ogv',  web_versions[:OGV][:nice][:file_name]
    assert_equal 'tiny.ogv',  web_versions[:OGV][:tiny][:file_name]
    assert_equal 'nice.webm', web_versions[:WEBM][:nice][:file_name]
    assert_equal 'tiny.webm', web_versions[:WEBM][:tiny][:file_name]
  end

  should 'know its tiniest_web_version' do
    video = create_and_proc_video 'atropelamento.ogv', 'video/ogg'
    tiniestOGV = video.tiniest_web_version :OGV
    tiniestWEBM = video.tiniest_web_version :WEBM
    assert_equal h2s({w:208,h:130}), h2s(tiniestOGV[:size])
    assert_equal :OGV, tiniestOGV[:type]
    assert_equal h2s({w:208,h:130}), h2s(tiniestWEBM[:size])
    assert_equal :WEBM, tiniestWEBM[:type]
    assert_equal nil, video.tiniest_web_version(:MP4)
  end

  should 'know if it has_ogv_version' do
    video = create_and_proc_video 'old-movie.mpg', 'video/mpeg'
    assert video.has_ogv_version
  end

  should 'know if it has_mp4_version' do
    video = create_and_proc_video 'old-movie.mpg', 'video/mpeg'
    assert not(video.has_mp4_version), 'must NOT to list MP4'
    video.web_versions[:MP4] = {SIZE: {file_name:'sized.mp4', status:'done'} }
    assert video.has_mp4_version, 'must to list MP4'
  end

  should 'know if it has_webm_version' do
    video = create_and_proc_video 'old-movie.mpg', 'video/mpeg'
    assert video.has_webm_version
  end

  should 'list its web_version_jobs' do
    videoA = FilePresenter::Video.new create_video 'old-movie.mpg', 'video/mpeg'
    videoB = FilePresenter::Video.new create_video 'atropelamento.ogv', 'video/ogg'
    jobA = videoA.web_version_jobs.map &:payload_object
    jobB = videoB.web_version_jobs.map &:payload_object
    # TODO: jobA.length must be 4.
    # `Html5VideoPlugin::uploaded_file_after_create_callback` is been called two times
    #assert_equal 4, jobA.length
    assert_equal Html5VideoPlugin::CreateVideoForWebJob, jobA[0].class
    assert_equal :OGV, jobA[0].format
    assert_equal :tiny, jobA[0].size
    assert_match /.*\/old-movie.mpg$/, jobA[0].full_filename
    assert_equal Html5VideoPlugin::CreateVideoForWebJob, jobA[1].class
    assert_equal :WEBM, jobA[1].format
    assert_equal :tiny, jobA[1].size
    assert_match /.*\/old-movie.mpg$/, jobA[1].full_filename
    assert_equal Html5VideoPlugin::CreateVideoForWebJob, jobA[2].class
    assert_equal :OGV, jobA[2].format
    assert_equal :nice, jobA[2].size
    assert_match /.*\/old-movie.mpg$/, jobA[1].full_filename
    assert_equal Html5VideoPlugin::CreateVideoForWebJob, jobA[3].class
    assert_equal :WEBM, jobA[3].format
    assert_equal :nice, jobA[3].size
    assert_match /.*\/old-movie.mpg$/, jobA[1].full_filename
    assert_equal Html5VideoPlugin::CreateVideoForWebJob, jobB[0].class
    assert_equal :OGV, jobB[0].format
    assert_equal :tiny, jobB[0].size
    assert_match /.*\/atropelamento.ogv$/, jobB[0].full_filename
    assert_equal Html5VideoPlugin::CreateVideoForWebJob, jobB[1].class
    assert_equal :WEBM, jobB[1].format
    assert_equal :tiny, jobB[1].size
    assert_match /.*\/atropelamento.ogv$/, jobB[1].full_filename
  end

  should 'list its web_preview_jobs' do
    videoA = FilePresenter::Video.new create_video 'old-movie.mpg', 'video/mpeg'
    videoB = FilePresenter::Video.new create_video 'atropelamento.ogv', 'video/ogg'
    jobA = videoA.web_preview_jobs.map &:payload_object
    jobB = videoB.web_preview_jobs.map &:payload_object
    # TODO: jobA.length must be 1.
    # `Html5VideoPlugin::uploaded_file_after_create_callback` is been called two times
    #assert_equal 1, jobA.length
    assert_equal Html5VideoPlugin::CreateVideoPreviewJob, jobA[0].class
    assert_match /.*\/old-movie.mpg$/, jobA[0].full_filename
    assert_equal Html5VideoPlugin::CreateVideoPreviewJob, jobB[0].class
    assert_match /.*\/atropelamento.ogv$/, jobB[0].full_filename
  end

  should 'know if it has_previews' do
    video = create_and_proc_video 'old-movie.mpg', 'video/mpeg'
    assert video.has_previews?
  end

  should 'list its image previews' do
    video = create_and_proc_video 'old-movie.mpg', 'video/mpeg'
    assert_equal h2s(big:'/web/preview_160x120.jpg', thumb:'/web/preview_107x80.jpg'), h2s(video.previews)
  end

  should 'set its image previews' do
    video = FilePresenter::Video.new create_video 'old-movie.mpg', 'video/mpeg'
    assert_equal nil, video.previews
    video.previews = {big:'big.jpg', thumb:'thumb.jpg'}
    assert_equal h2s(big:'big.jpg', thumb:'thumb.jpg'), h2s(video.previews)
  end

  should 'get image_preview for a processed video' do
    video = create_and_proc_video 'old-movie.mpg', 'video/mpeg'
    assert_match /\/[0-9]+\/web\/preview_160x120\.jpg/, video.image_preview(:big)
  end

  should 'get default image_preview for non processed video' do
    video = FilePresenter::Video.new create_video 'old-movie.mpg', 'video/mpeg'
    assert_match /\/html5_video\/images\/video-preview-big\.png/, video.image_preview(:big)
  end

  should 'list its conversion_errors' do
    video = FilePresenter::Video.new create_video 'old-movie.mpg', 'video/mpeg'
    video.web_versions[:MP4] = {nice: {status:'error converting', error:{code:-99,message:'some error',output:'abcde'}} }
    assert_equal h2s(MP4:{nice:{code:-99,message:'some error',output:'abcde'}}), h2s(video.conversion_errors)
  end

end
