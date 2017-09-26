require_relative '../video_processor/video_data'

module VideoProcessor
  class Converter

    attr_accessor :logger
    attr_reader :video

    def initialize(ffmpeg, video_path, video_id)
      @ffmpeg = ffmpeg
      @video_path = video_path
      @video_id = video_id

      info = @ffmpeg.get_video_info(@video_path)
      if info[:error][:code] == 0
        @video = VideoProcessor::VideoData.new(info)
      else
        raise IOError.new(info[:error][:message])
      end
    end

    def create_preview_imgs
      logger.info "Generating previews for [Video #{@video_id}]"
      previews = @ffmpeg.video_thumbnail(@video_path)
      if previews.is_a?(Hash) &&
         previews[:error] && previews[:error][:code] != 0
        logger.error "Error generating '#{@video_path}' previews: #{previews[:error][:message]}"
        previews = :fail
      end
      previews
    end

    def create_web_videos
      responses = { OGV: {}, WEBM: {} }
      [:OGV, :WEBM].each do |format|
        responses[format][:tiny] = convert_to_tiny(format)
        responses[format][:nice] = convert_to_nice(format)
      end
      responses
    end

    def info
      video.info
    end

    private

    def convert_to_tiny(format)
      logger.info "Generating tiny #{format} for [Video #{@video_id}]"
      audio_stream = info[:streams].find{ |s| s[:type] == 'audio' }
      abrate = audio_stream.nil? ? 64 : audio_stream[:bitrate] || 64
      abrate = 64 if abrate > 64
      conf = { size_name: 'tiny', in: @video_path,
               fps: 12, vbrate: 250, abrate: abrate }

      if video.is_big
        # Low weight video dimension for each Aspect Ratio:
        #  * 320x240 for 4:3
        #  * 320x180 for 16:9
        # This are Best and Good values with the same width based on this page:
        # http://www.flashsupport.com/books/fvst/files/tools/video_sizes.html
        h = ( 320.0 / (video.size[:w].to_f / video.size[:h].to_f) ).round
        h -= 1 if h % 2 == 1
        size = { w: 320, h: h }
        conf[:size] = size
      end
      if format == :OGV && ( video.is_big || ! video.is_ogv )
        conf[:file_name] = 'tiny.ogv'
        result = @ffmpeg.make_ogv_for_web(conf)
      end
      if format == :WEBM && ( video.is_big || ! video.is_webm )
        conf[:file_name] = 'tiny.webm'
        result = @ffmpeg.make_webm_for_web(conf)
      end
      check_for_error(result, format)
      result
    end

    def convert_to_nice(format)
      logger.info "Generating nice #{format} for [Video #{@video_id}]"
      if video.is_toobig
        # Max video dimension for each Aspect Ratio:
        #  * 576x432 for 4:3
        #  * 576x324 for 16:9
        # This are Best and Good values with the same width based on this page:
        # http://www.flashsupport.com/books/fvst/files/tools/video_sizes.html
        # Width 640 has Better result to 16:9, but that will also make bigger
        # file weight.
        h = ( 576.0 / (video.size[:w].to_f / video.size[:h].to_f) ).round
        size = { w: 576, h: h.to_i }
        conf = { in: @video_path, size: size, vbrate: video.brate }
      else
        conf = { in: @video_path, vbrate: video.brate }
      end
      conf[:size_name] = 'nice'
      if format == :OGV && ( video.is_toobig || ! video.is_ogv )
        conf[:file_name] = 'nice.ogv'
        result = @ffmpeg.make_ogv_for_web(conf)
      end
      if format == :WEBM && ( video.is_toobig || ! video.is_webm )
        conf[:file_name] = 'nice.webm'
        result = @ffmpeg.make_webm_for_web(conf)
      end
      check_for_error(result, format)
      result
    end

    def check_for_error(result, format)
      if result[:error][:code] != 0
        logger.error "FFmpeg ERROR while converting '#{@video_path}' to #{format}: #{result[:error][:message]}"
      end
    end

  end
end
