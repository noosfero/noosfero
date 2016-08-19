class Html5VideoPlugin::CreateVideoForWebJob

  # TODO: we must to add timeout to ffmpeg to allow this object to set this on error:
  # @video.video_info[:conversion] = :timeout
  # TODO: must remove web folder when delete the video

  attr_accessor :file_type, :file_id, :full_filename, :format, :size

  def perform
    return unless file_type.constantize.exists?(file_id)
    @ffmpeg = Html5VideoPlugin::Ffmpeg.new

    @video = FilePresenter.for file_type.constantize.find(file_id)
    throw "Expected file #{file_id} to be a video" unless @video.is_a?(FilePresenter::Video)

    @video_file = full_filename

    @info = @ffmpeg.get_video_info @video_file

    if @info[:error][:code] == 0
      @video.original_video = @info.except :output
      register_conv_status 'started'
      @video.save!
    else
      register_conv_status 'error reading'
      register_conv_error @info[:error]
      @video.save!
      Rails.logger.error "FFmpeg ERROR while reading '#{@video_file}': #{@info[:error][:message]}"
      return
    end
    
    @orig_size = @info.video_stream[0][:size]
    @brate = @info.video_stream[0][:bitrate] || @info[:global_bitrate] || 400

    convert_to_tiny if size == :tiny
    convert_to_nice if size == :nice
    @video.save!
    1
  end

  def register_conv_status( status )
    @video.web_versions[format] ||= {}
    @video.web_versions[format][size] ||= {}
    @video.web_versions[format][size][:status] = status
    @video.save!
  end

  def register_conv_conf( conf )
    @video.web_versions[format] ||= {}
    @video.web_versions[format][size] ||= {}
    @video.web_versions[format][size].merge! conf
    @video.save!
  end

  def register_conv_error( error )
    @video.web_versions[format] ||= {}
    @video.web_versions[format][size] ||= {}
    @video.web_versions[format][size][:error] = error
    @video.save!
  end

  def is_ogv
    @info[:type] == 'ogv' &&
    @info.video_stream[0][:codec] == 'theora' &&
    @info.audio_stream[0][:codec] == 'vorbis'
  end

  def is_mp4
    @info[:type] == 'mp4' &&
    @info.video_stream[0][:codec] == 'libx264' &&
    @info.audio_stream[0][:codec] == 'libfaac'
  end

  def is_webm
    @info[:type] == 'webm' &&
    @info.video_stream[0][:codec] == 'libvpx'
  end

  def register_conversion response
    conf = response[:conf].clone
    if response[:error][:code] == 0
      conf[:path] = conf[:out].sub /^.*(\/articles)/, '\1'
      conf.delete :in
      conf.delete :out
      register_conv_conf conf
      register_conv_status 'done'
      @video.save!
    else
      register_conv_status 'error converting'
      register_conv_conf conf
      error = response[:error].clone
      error[:output] = response[:output]
      register_conv_error error
      Rails.logger.error "FFmpeg ERROR while converting '#{conf[:in]}' to #{conf[:type]}: #{response[:error][:message]}"
    end
  end

  def is_big
    @orig_size[:w] > 400 || @brate >= 400
  end

  def is_toobig
    @orig_size[:w] > 600
  end

  # The smaller version for slow connections
  def convert_to_tiny
    audio_stream = @video.original_video[:streams].find{|s| s[:type] == 'audio'}
    abrate = audio_stream.nil? ? 64 : audio_stream[:bitrate] || 64
    abrate = 64 if abrate > 64
    conf = { :size_name=>'tiny', :in=>@video_file,
             :fps=>12, :vbrate=>250, :abrate=>abrate }
    if is_big
      # Low weight video dimension for each Aspect Ratio:
      #  * 320x240 for 4:3
      #  * 320x180 for 16:9
      # This are Best and Good values with the same width based on this page:
      # http://www.flashsupport.com/books/fvst/files/tools/video_sizes.html
      h = ( 320.0 / (@orig_size[:w].to_f/@orig_size[:h].to_f) ).round
      h -= 1 if h % 2 == 1
      size = { :w=>320, :h=>h }
      conf[:size] = size
    end
    if format == :OGV && ( is_big || ! is_ogv )
      conf[:file_name] = 'tiny.ogv'
      register_conversion @ffmpeg.make_ogv_for_web(conf)
    end
    if format == :WEBM && ( is_big || ! is_webm )
      conf[:file_name] = 'tiny.webm'
      register_conversion @ffmpeg.make_webm_for_web(conf)
    end
  end

  # The nicer common version
  def convert_to_nice
    if is_toobig
      # Max video dimension for each Aspect Ratio:
      #  * 576x432 for 4:3
      #  * 576x324 for 16:9
      # This are Best and Good values with the same width based on this page:
      # http://www.flashsupport.com/books/fvst/files/tools/video_sizes.html
      # Width 640 has Better result to 16:9, but that will also make bigger
      # file weight.
      h = ( 576.0 / (@orig_size[:w].to_f/@orig_size[:h].to_f) ).round
      size = { :w=>576, :h=>h.to_i }
      conf = { :in=>@video_file, :size=>size, :vbrate=>@brate }
    else
      conf = { :in=>@video_file, :vbrate=>@brate }
    end
    conf[:size_name] = 'nice'
    if format == :OGV && ( is_toobig || ! is_ogv )
      conf[:file_name] = 'nice.ogv'
      register_conversion @ffmpeg.make_ogv_for_web(conf)
    end
    if format == :WEBM && ( is_toobig || ! is_webm )
      conf[:file_name] = 'nice.webm'
      register_conversion @ffmpeg.make_webm_for_web(conf)
    end
  end

end
