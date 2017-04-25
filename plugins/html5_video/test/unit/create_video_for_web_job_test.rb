require 'test_helper'
require_relative '../download_fixture'

class CreateVideoForWebJobTest < ActiveSupport::TestCase

  ffmpeg = Html5VideoPlugin::Ffmpeg.new

  def setup
    Environment.default.enable_plugin Html5VideoPlugin
    # Create a temporary directory to write testing files
    @temp = %x{ mktemp -d }[0..-2]
  end

  def teardown
    # Remove the temporary directory
    %x{ rm -r '#{@temp}' }
  end

  def run_CreateVideoForWebJobs_for_video(video)
    jobs = video.web_version_jobs
    # Run all CreateVideoForWebJob's for this created video:
    print '['; STDOUT.flush
    jobs.each do |job|
      YAML.load(job.handler).perform
      STDOUT.write '+'; STDOUT.flush # a progress to the user see something.
    end
    print ']'; STDOUT.flush
    video.reload
  end

  should 'create web compatible version to a uploaded MPEG video' do
    video = FilePresenter.for UploadedFile.create!(
      :uploaded_data => fixture_file_upload('/videos/old-movie.mpg', 'video/mpeg'),
      :profile => fast_create(Person) )
    assert_equal({}, video.web_versions, 'video.web_versions starts as empty list')

    run_CreateVideoForWebJobs_for_video(video)

    video.web_versions.each do |format, format_block|
      format_block.each { |size, video_conv| assert !video_conv[:original] }
    end
    assert_equal 'tiny.ogv',        video.web_versions[:OGV][:tiny][:file_name]
    assert_equal({:w=>320,:h=>212}, video.web_versions[:OGV][:tiny][:size])
    assert_equal 250,               video.web_versions[:OGV][:tiny][:vbrate]
    assert_equal 64,                video.web_versions[:OGV][:tiny][:abrate]
    assert_equal 'nice.ogv',        video.web_versions[:OGV][:nice][:file_name]
    assert_equal({:w=>576,:h=>384}, video.web_versions[:OGV][:nice][:size])
    assert_equal 104857,            video.web_versions[:OGV][:nice][:vbrate]
    assert_equal 128,               video.web_versions[:OGV][:nice][:abrate]
    assert_equal 'tiny.webm',       video.web_versions[:WEBM][:tiny][:file_name]
    assert_equal({:w=>320,:h=>212}, video.web_versions[:WEBM][:tiny][:size])
    assert_equal 250,               video.web_versions[:WEBM][:tiny][:vbrate]
    assert_equal 64,                video.web_versions[:WEBM][:tiny][:abrate]
    assert_equal 'nice.webm',       video.web_versions[:WEBM][:nice][:file_name]
    assert_equal({:w=>576,:h=>384}, video.web_versions[:WEBM][:nice][:size])
    assert_equal 104857,            video.web_versions[:WEBM][:nice][:vbrate]
    assert_equal 128,               video.web_versions[:WEBM][:nice][:abrate]

    webdir = ffmpeg.webdir_for_original_video video.public_filename
    assert File.exists?( webdir+'/tiny.ogv' )
    assert File.exists?( webdir+'/nice.ogv' )
    assert File.exists?( webdir+'/tiny.webm' )
    assert File.exists?( webdir+'/nice.webm' )
  end

  should 'create web compatible version to a uploaded OGG video' do
    resp = ffmpeg.run [ :i, "#{fixture_path}/videos/firebus.3gp",
                        :t, 4, :f, 'ogg',
                        :vcodec, 'libtheora', :vb, '800k',
                        :acodec, 'libvorbis', :ar, 44100, :ab, '192k',
                        "#{@temp}/firebus.ogv" ]
    assert_equal 0, resp[:error][:code], 'creating a valid OGV'

    video = FilePresenter.for UploadedFile.create!(
      uploaded_data: Rack::Test::UploadedFile.new("#{@temp}/firebus.ogv", 'video/ogv'),
      profile: fast_create(Person) )
    assert_equal({}, video.web_versions, 'video.web_versions starts as empty list')

    run_CreateVideoForWebJobs_for_video(video)

    video.web_versions.each do |format, format_block|
      format_block.each { |size, video_conv| assert !video_conv[:original] }
    end
    web_versions = video.web_versions!
    assert_equal 'tiny.ogv',        web_versions[:OGV][:tiny][:file_name]
    assert_equal({:w=>320,:h=>240}, web_versions[:OGV][:tiny][:size])
    assert_equal 250,               web_versions[:OGV][:tiny][:vbrate]
    assert_equal 64,                web_versions[:OGV][:tiny][:abrate]
    assert_equal 'tiny.webm',       web_versions[:WEBM][:tiny][:file_name]
    assert_equal({:w=>320,:h=>240}, web_versions[:WEBM][:tiny][:size])
    assert_equal 250,               web_versions[:WEBM][:tiny][:vbrate]
    assert_equal 64,                web_versions[:WEBM][:tiny][:abrate]
    assert_equal 'firebus.ogv',     web_versions[:OGV][:orig][:file_name]
    assert_equal({:w=>128,:h=>96},  web_versions[:OGV][:orig][:size])
    assert_equal 192,               web_versions[:OGV][:orig][:abrate]
  end

end
