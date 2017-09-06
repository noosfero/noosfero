require 'test_helper'
require_relative '../download_fixture'
require_relative '../html5_video_plugin_test_helper'

class ConverterTest < ActiveSupport::TestCase

  prepend Html5VideoPluginTestHelper

  def setup
    Environment.default.enable_plugin Html5VideoPlugin
    @video = FilePresenter.for UploadedFile.create!(
      :uploaded_data => fixture_file_upload('/videos/firebus.3gp', 'video/3gp'),
      :profile => fast_create(Person)
    )

    @ffmpeg = VideoProcessor::Ffmpeg.new
    @converter = VideoProcessor::Converter.new(@ffmpeg, @video.full_filename,
                                               @video.id)

    @logger = mock
    @logger.expects(:info).at_least(0)
    @logger.expects(:error).at_least(0)
    @converter.logger = @logger

    # Create a temporary directory to write testing files
    @temp = %x{ mktemp -d }[0..-2]
  end

  def teardown
    # Remove the temporary directory
    %x{ rm -r '#{@temp}' }
  end

  should 'create preview images to uploaded videos' do
    previews = @converter.create_preview_imgs
    assert_equal({ :big   => '/web/preview_160x120.jpg',
                   :thumb => '/web/preview_107x80.jpg' }, previews)

    video_path = File.dirname(@video.full_filename)
    assert File.exist?(video_path + previews[:big])
    assert File.exist?(video_path + previews[:thumb])
    assert_match /^\/[^ ]*\/[0-9]+\/+web\/preview_160x120.jpg JPEG 160x720 /, `identify #{video_path + previews[:big]}`
    assert_match /^\/[^ ]*\/[0-9]+\/+web\/preview_107x80.jpg JPEG 107x480 /, `identify #{video_path + previews[:thumb]}`
  end

  should 'should not instantiate converter if file does not exist' do
    assert_raise do
      VideoProcessor::Converter.new(@ffmpeg, 'nope', 404)
    end
  end

  should 'not create thumbnails if ffmpeg fails' do
    @ffmpeg.stubs(:video_thumbnail).returns({ error: { code: 1, message: '' } })
    previews = @converter.create_preview_imgs
    assert_equal :fail, previews
  end

  should 'create all web versions for a MPEG video' do
    video = FilePresenter.for UploadedFile.create!(
      :uploaded_data => fixture_file_upload('/videos/old-movie.mpg', 'video/mpeg'),
      :profile => fast_create(Person)
    )
    converter = VideoProcessor::Converter.new(@ffmpeg, video.full_filename,
                                              video.id)
    converter.logger = @logger

    assert video.web_versions.blank?, 'video.web_versions starts as empty list'
    video.web_versions.each do |format, format_block|
      format_block.each { |size, conv| assert conv[:original].blank? }
    end

    versions = converter.create_web_videos
    assert_equal 'tiny.ogv',        versions[:OGV][:tiny][:conf][:file_name]
    assert_equal({:w=>320,:h=>212}, versions[:OGV][:tiny][:conf][:size])
    assert_equal 250,               versions[:OGV][:tiny][:conf][:vbrate]
    assert_equal 64,                versions[:OGV][:tiny][:conf][:abrate]
    assert_equal 'nice.ogv',        versions[:OGV][:nice][:conf][:file_name]
    assert_equal({:w=>576,:h=>384}, versions[:OGV][:nice][:conf][:size])
    assert_equal 104857,            versions[:OGV][:nice][:conf][:vbrate]
    assert_equal 128,               versions[:OGV][:nice][:conf][:abrate]
    assert_equal 'tiny.webm',       versions[:WEBM][:tiny][:conf][:file_name]
    assert_equal({:w=>320,:h=>212}, versions[:WEBM][:tiny][:conf][:size])
    assert_equal 250,               versions[:WEBM][:tiny][:conf][:vbrate]
    assert_equal 64,                versions[:WEBM][:tiny][:conf][:abrate]
    assert_equal 'nice.webm',       versions[:WEBM][:nice][:conf][:file_name]
    assert_equal({:w=>576,:h=>384}, versions[:WEBM][:nice][:conf][:size])
    assert_equal 104857,            versions[:WEBM][:nice][:conf][:vbrate]
    assert_equal 128,               versions[:WEBM][:nice][:conf][:abrate]

    webdir = @ffmpeg.webdir_for_original_video video.public_filename
    assert File.exists?( webdir+'/tiny.ogv' )
    assert File.exists?( webdir+'/nice.ogv' )
    assert File.exists?( webdir+'/tiny.webm' )
    assert File.exists?( webdir+'/nice.webm' )
  end

  should 'create all web versions for an OGG video' do
    resp = @ffmpeg.run [ :i, "#{fixture_path}/videos/firebus.3gp",
                         :t, 4, :f, 'ogg',
                         :vcodec, 'libtheora', :vb, '800k',
                         :acodec, 'libvorbis', :ar, 44100, :ab, '192k',
                         "#{@temp}/firebus.ogv" ]
    assert_equal 0, resp[:error][:code], 'creating a valid OGV'

    video = FilePresenter.for UploadedFile.create!(
      uploaded_data: Rack::Test::UploadedFile.new("#{@temp}/firebus.ogv", 'video/ogv'),
      profile: fast_create(Person) )
    converter = VideoProcessor::Converter.new(@ffmpeg, video.full_filename,
                                              video.id)
    converter.logger = @logger

    assert_equal({}, video.web_versions, 'video.web_versions starts as empty list')
    video.web_versions.each do |format, format_block|
      format_block.each { |size, conv| assert conv[:original].blank? }
    end

    versions = converter.create_web_videos
    assert_equal 'tiny.ogv',        versions[:OGV][:tiny][:conf][:file_name]
    assert_equal({:w=>320,:h=>240}, versions[:OGV][:tiny][:conf][:size])
    assert_equal 250,               versions[:OGV][:tiny][:conf][:vbrate]
    assert_equal 64,                versions[:OGV][:tiny][:conf][:abrate]
    assert_equal 'tiny.webm',       versions[:WEBM][:tiny][:conf][:file_name]
    assert_equal({:w=>320,:h=>240}, versions[:WEBM][:tiny][:conf][:size])
    assert_equal 250,               versions[:WEBM][:tiny][:conf][:vbrate]
    assert_equal 64,                versions[:WEBM][:tiny][:conf][:abrate]
  end

end
