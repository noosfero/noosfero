class VideoProcessor::VideoData

  attr_reader :info, :size, :brate

  def initialize(info)
    @info = info
    @size = info.video_stream[0][:size]
    @brate = info.video_stream[0][:bitrate] || info[:global_bitrate] || 400
  end

  def is_big
    @size[:w] > 400 || @brate >= 400
  end

  def is_toobig
    @size[:w] > 600
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

end
