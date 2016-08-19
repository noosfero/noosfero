#require File.dirname(__FILE__) + '/../../../../test/test_helper'
require 'test_helper'
#require File.dirname(__FILE__) + '/../download_fixture'
require_relative '../download_fixture'
$LOAD_PATH << File.dirname(__FILE__) + '/../../lib/'
require 'html5_video_plugin.rb'
require 'html5_video_plugin/ffmpeg.rb'

class FfmpegTest < ActiveSupport::TestCase

  ffmpeg = Html5VideoPlugin::Ffmpeg.new

  def create_video(file, mime)
    file = UploadedFile.create!(
      :uploaded_data => fixture_file_upload('/videos/'+file, mime),
      :profile => fast_create(Person))
  end

  def video_path(file='')
    "#{fixture_path}/videos/#{file}"
  end

  # Some tests wil create a "web" dir inside fixture videos dir, so we must remove it.
  def rm_web_videos_dir
    webdir = video_path 'web'
    return unless Dir.exist? webdir
    Dir.foreach(webdir) do|file|
      File.unlink webdir +'/'+ file unless file.match /^\.+$/
    end
    Dir.delete webdir
  end

  def setup
    Environment.default.enable_plugin Html5VideoPlugin
    @temp = []
    rm_web_videos_dir
  end

  def teardown
    @temp.each do |file|
      if File.exist? file
        File.unlink file
      end
    end
    rm_web_videos_dir
  end

  # Create a temp filename, not a file.
  # If a file with this name is created, it will be removed by the teardown.
  def mkTempName(ext='')
    ( @temp << "/tmp/#{SecureRandom.hex}.#{ext}" ).last
  end

  should 'has the right version of ffmpeg' do
    response = ffmpeg.run :version
    assert_match /^ffmpeg version 3\.0/, response[:output]
  end

  should 'complain about missing input' do
    response = ffmpeg.run :i, 'ups-i-dont-exixt.ogv'
    assert_equal 1, response[:error][:code]
  end

  should 'complain about missing output' do
    response = ffmpeg.run :i, video_path('old-movie.mpg')
    assert_equal 2, response[:error][:code]
  end

  should 'complain about unknown encoder' do
    tmpogv = mkTempName :ogv
    response = ffmpeg.run :i, video_path('old-movie.mpg'), :vcodec, 'noCodec', tmpogv
    assert_equal 3, response[:error][:code]
  end

  should 'complain about wrong encoder' do
    tmpvid = mkTempName :mpg
    response = ffmpeg.run :i, video_path('firebus.3gp'), :'b:v', 3, tmpvid
    assert_equal 4, response[:error][:code]
  end

#  #TODO: cant reproduce this error
#  should 'complain about not being able to open encoder' do
#    tmpvid = mkTempName :mpg
#    response = run_ffmpeg [:i, video_path('old-movie.mpg'), tmpvid]
#    assert_equal 5, response[:error][:code]
#  end

#  #TODO: cant reproduce this error
#  should 'complain about unsuported codec' do
#    tmpvid = mkTempName :webm
#    response = run_ffmpeg [:i, video_path('firebus.3gp'), :vcodec, 'libtheora', tmpvid]
#    assert_equal 6, response[:error][:code]
#  end

  should 'complain about unknown output format' do
    tmpvid = mkTempName :nop
    response = ffmpeg.run :i, video_path('old-movie.mpg'), tmpvid
    assert_equal 7, response[:error][:code]
  end

  should 'complain about invalid input data' do
    tmpvid = mkTempName :mpg
    fakevid = Tempfile.new ['fake', '.mpg']
    response = ffmpeg.run :i, fakevid.path, tmpvid
    fakevid.close
    fakevid.unlink
    assert_equal 8, response[:error][:code]
  end

  should 'read ffmpeg information and features' do
    response = ffmpeg.register_information
    assert_match /^[0-9]\.[0-9]\.[0-9]$/, response[:version]
    formatWebM = /^\{demux:false,description:WebM,mux:true\}$/
    assert_match formatWebM, h2s(response[:formats][:webm])
    codecVorbis = /^\{decode:true,description:Vorbis[^,]+,direct_rendering:false,draw_horiz_band:false,encode:true,type:audio,wf_trunc:false\}$/
    assert_match codecVorbis, h2s(response[:codecs][:vorbis])
  end

  should 'convert time string to seconds int' do
    assert_equal 30, ffmpeg.timestr_to_secs('00:00:30')
    assert_equal 630, ffmpeg.timestr_to_secs('00:10:30')
    assert_equal 7830, ffmpeg.timestr_to_secs('02:10:30')
    assert_equal nil, ffmpeg.timestr_to_secs('invalid time string')
  end

  should 'parse video stream info' do
    response = ffmpeg.get_stream_info 'Stream #0:0[0x1e0]: Video: mpeg1video, yuv420p(tv), 720x480 [SAR 200:219 DAR 100:73], 104857 kb/s, 23.98 fps, 23.98 tbr, 90k tbn, 23.98 tbc'

    assert_equal 'video', response[:type]
    assert_equal 'mpeg1video', response[:codec]
    assert_equal 104857, response[:bitrate]
    assert_equal 23.98, response[:framerate]
    assert_equal 'video', response[:type]
    assert_equal 720, response[:size][:w]
    assert_equal 480, response[:size][:h]
  end

  should 'parse audio stream info' do
    response = ffmpeg.get_stream_info 'Stream #0:1[0x1c0]: Audio: mp2, 48000 Hz, 2 channels, stereo, s16p, 128 kb/s'
    assert_equal 'audio', response[:type]
    assert_equal 'mp2', response[:codec]
    assert_equal 48000, response[:frequency]
    assert_equal 128, response[:bitrate]
    assert_equal 2, response[:channels]
  end

  should 'fetch webdir' do
    video = mkTempName :mpg
    assert_equal '/tmp/web', ffmpeg.webdir_for_original_video(video)
  end

  should 'validate conversion conf for web' do
    conf = { in: video_path('old-movie.mpg') }
    validConf = ffmpeg.validate_conversion_conf_for_web conf, :webm
    assert_match /^\{abrate:128,file_name:640x426_1024.webm,in:[^:]+\/old-movie.mpg,out:[^:]+\/web\/640x426_1024.webm,size:\{h:426,w:640\},vbrate:1024\}$/, h2s(validConf)
  end

  should 'validate conversion conf for web with given output filename' do
    conf = { in: video_path('old-movie.mpg'), file_name: 'test.webm' }
    validConf = ffmpeg.validate_conversion_conf_for_web conf, :webm
    assert_match /^\/.+\/web\/test.webm$/, validConf[:out]
  end

  should 'get video info' do
    resp = ffmpeg.get_video_info video_path('old-movie.mpg')
    assert_equal [:error, :parameters, :output, :metadata, :type, :duration, :global_bitrate, :streams], resp.keys
    assert_equal '{code:0,message:Success.}', h2s(resp[:error])
    assert_equal 'mpeg', resp[:type]
    assert_equal 5, resp[:duration]
    assert_equal 2428, resp[:global_bitrate]
    assert_equal '{}', h2s(resp[:metadata])
    assert_match /^\[i,\/[^,]*\/videos\/old-movie.mpg\]$/, h2s(resp[:parameters])
    assert_match /^\{bitrate:104857,codec:mpeg1video,framerate:23.98,id:#0,size:\{h:480,w:720\},type:video\}$/, h2s(resp[:streams][0])
    assert_match /^\{bitrate:128,codec:mp2,frequency:48000,id:#0,type:audio\}$/, h2s(resp[:streams][1])
  end

  should 'get video info with metadata' do
    resp = ffmpeg.get_video_info video_path('atropelamento.ogv')
    assert_equal '{comment:Stop-motion movie,title:Atropelamento}', h2s(resp[:metadata])
  end

  should 'convert to OGV' do
    out_video = mkTempName :ogv
    resp = ffmpeg.convert2ogv in: video_path('old-movie.mpg'), out: out_video
    assert_equal [:error, :parameters, :output, :conf], resp.keys
    assert_equal '{code:0,message:}', h2s(resp[:error])
    assert_match /^\[i,\/[^,]*\/videos\/old-movie.mpg,y,b:v,600k,f,ogg,acodec,libvorbis,vcodec,libtheora,\/tmp\/[^,\/]*.ogv\]$/, h2s(resp[:parameters])
    assert_match /^\{in:\/[^,]*\/videos\/old-movie.mpg,out:\/tmp\/[^,\/]*.ogv,type:OGV,vbrate:600\}$/, h2s(resp[:conf])
    assert File.exist? out_video
  end

  should 'convert to MP4' do
    out_video = mkTempName :mp4
    resp = ffmpeg.convert2mp4 in: video_path('old-movie.mpg'), out: out_video
    assert_equal [:error, :parameters, :output, :conf], resp.keys
    assert_equal '{code:0,message:}', h2s(resp[:error])
    assert_match /^\[i,\/[^,]*\/videos\/old-movie.mpg,y,b:v,600k,preset,slow,f,mp4,acodec,aac,vcodec,libx264,strict,-2,\/tmp\/[^,\/]*.mp4\]$/, h2s(resp[:parameters])
    assert_match /^\{in:\/[^,]*\/videos\/old-movie.mpg,out:\/tmp\/[^,\/]*.mp4,type:MP4,vbrate:600\}$/, h2s(resp[:conf])
    assert File.exist? out_video
  end

  should 'convert to WebM' do
    out_video = mkTempName :webm
    resp = ffmpeg.convert2webm in: video_path('old-movie.mpg'), out: out_video
    assert_equal [:error, :parameters, :output, :conf], resp.keys
    assert_equal '{code:0,message:}', h2s(resp[:error])
    assert_match /^\[i,\/[^,]*\/videos\/old-movie.mpg,y,b:v,600k,f,webm,acodec,libvorbis,vcodec,libvpx,\/tmp\/[^,\/]*.webm\]$/, h2s(resp[:parameters])
    assert_match /^\{in:\/[^,]*\/videos\/old-movie.mpg,out:\/tmp\/[^,\/]*.webm,type:WEBM,vbrate:600\}$/, h2s(resp[:conf])
    assert File.exist? out_video
  end

  should 'convert to OGV for the web' do
    resp = ffmpeg.make_ogv_for_web in: video_path('old-movie.mpg')
    assert_equal [:error, :parameters, :output, :conf], resp.keys
    assert_equal '{code:0,message:}', h2s(resp[:error])
    assert_match /^\[i,\/[^,]*\/videos\/old-movie.mpg,y,b:v,1024k,f,ogg,acodec,libvorbis,vcodec,libtheora,s,640x426,b:a,128k,\/[^,]*\/videos\/web\/640x426_1024.ogv\]$/, h2s(resp[:parameters])
    assert_match /^\/[^,]*\/videos\/web\/640x426_1024.ogv$/, resp[:conf][:out]
    assert File.exist? resp[:conf][:out]
  end

  should 'convert to MP4 for the web' do
    resp = ffmpeg.make_mp4_for_web in: video_path('old-movie.mpg')
    assert_equal [:error, :parameters, :output, :conf], resp.keys
    assert_equal '{code:0,message:}', h2s(resp[:error])
    assert_match /^\[i,\/[^,]*\/videos\/old-movie.mpg,y,b:v,1024k,preset,slow,f,mp4,acodec,aac,vcodec,libx264,strict,-2,s,640x426,b:a,128k,\/[^,]*\/videos\/web\/640x426_1024.mp4\]$/, h2s(resp[:parameters])
    assert_match /^\/[^,]*\/videos\/web\/640x426_1024.mp4$/, resp[:conf][:out]
    assert File.exist? resp[:conf][:out]
  end

  should 'convert to WebM for the web' do
    resp = ffmpeg.make_webm_for_web in: video_path('old-movie.mpg')
    assert_equal [:error, :parameters, :output, :conf], resp.keys
    assert_equal '{code:0,message:}', h2s(resp[:error])
    assert_match /^\[i,\/[^,]*\/videos\/old-movie.mpg,y,b:v,1024k,f,webm,acodec,libvorbis,vcodec,libvpx,s,640x426,b:a,128k,\/[^,]*\/videos\/web\/640x426_1024.webm\]$/, h2s(resp[:parameters])
    assert_match /^\/[^,]*\/videos\/web\/640x426_1024.webm$/, resp[:conf][:out]
    assert File.exist? resp[:conf][:out]
  end

  should 'create video thumbnail' do
    resp = ffmpeg.video_thumbnail video_path('old-movie.mpg')
    assert_match /^\/web\/preview_160x120.jpg$/, resp[:big]
    assert_match /^\/web\/preview_107x80.jpg$/, resp[:thumb]
    assert File.exist?(video_path resp[:big])
    assert File.exist?(video_path resp[:thumb])
    assert_match /^\/[^ ]*\/videos\/+web\/preview_160x120.jpg JPEG 160x720 /, `identify #{video_path resp[:big]}`
    assert_match /^\/[^ ]*\/videos\/+web\/preview_107x80.jpg JPEG 107x480 /, `identify #{video_path resp[:thumb]}`
  end

  should 'recognize ffmpeg version' do
    assert_match /^[0-9]\.[0-9]\.[0-9]$/, ffmpeg.version
  end

  should 'list supported formats' do
    formatMpeg = /^\{demux:true,description:MPEG-1 Systems[^}]+,mux:true\}$/
    formatWebM = /^\{demux:false,description:WebM,mux:true\}$/
    assert_match formatMpeg, h2s(ffmpeg.formats[:mpeg])
    assert_match formatWebM, h2s(ffmpeg.formats[:webm])
  end

  should 'list supported codecs' do
    codecOpus = /^\{decode:true,description:Opus[^,]+,direct_rendering:false,draw_horiz_band:false,encode:true,type:audio,wf_trunc:false\}$/
    codecVorb = /^\{decode:true,description:Vorbis[^,]+,direct_rendering:false,draw_horiz_band:false,encode:true,type:audio,wf_trunc:false\}$/
    assert_match codecOpus, h2s(ffmpeg.codecs[:opus])
    assert_match codecVorb, h2s(ffmpeg.codecs[:vorbis])
  end

end
