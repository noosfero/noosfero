# Creates the namespace, so we can use the lib classes
module VideoProcessor; end

require_relative '../lib/video_processor/ffmpeg'
require_relative '../lib/video_processor/pool_manager'
require_relative '../lib/video_processor/recorder'
require_relative '../lib/video_processor/converter'
require_relative '../lib/video_processor/logger'

include VideoProcessor::Recorder

RAILS_ENV = ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development'
NOOSFERO_ROOT = File.join(__dir__, '../../../')
POOL = VideoProcessor::PoolManager.new(NOOSFERO_ROOT)

# Creates the pool dir if it does not exist
POOL.init_pools

LOGGER = VideoProcessor::Logger.new(File.join(NOOSFERO_ROOT, 'log'))

# Redirects stdout and stderr to log files
unless RAILS_ENV == 'test'
  $stdout.reopen(LOGGER.info_log_path, "a")
  $stderr.reopen(LOGGER.info_log_path, "a")
end

# Watches pool dir using inotifywait
def watch_pool
  IO.popen("inotifywait -r -m -e create #{POOL.waiting_pool}") do |output|
    output.each do |line|
      path, events, filename = line.split
      if events.include? 'ISDIR'
        # A subfolder for the environment was created.
        env_id = filename
      else
        # A new file was added
        env_id = path.split('/').last
      end

      # inotify may lose some events, so run for all files every time
      sleep(0.5) # FIXME wait until the file was written
      process_all_files(env_id)
    end
  end
end

# Processes every file inside an environment subfolder
def process_all_files(env_id, pool=:waiting)
  POOL.all_files(env_id, pool).map do |file|
    # Moves the file to the ONGOING pool, so we can try again if the process
    # dies during the conversion. It removes the file from the pool if it was
    # processed, or adds it back to the WAITING pool if something went wrong.
    Process.fork do
      video_id = file.split('/').last
      video_path = POOL.assign(env_id, video_id, pool)
      begin
        process_video(env_id, video_path, video_id)
        POOL.pop(env_id, video_id)
      rescue => e
        LOGGER.error "Error while processing [Video #{video_id}]: #{e}"
        POOL.pop(env_id, video_id)
        POOL.push(env_id, video_id, video_path)
      end
    end
  end
end

# Processes a single video file. It will:
# - Generate preview images
# - Convert video to web formats
def process_video(env_id, video_path, video_id)
  LOGGER.info "Processing [Video #{video_id}] (#{video_path})"
  ffmpeg = VideoProcessor::Ffmpeg.new

  begin
    converter = VideoProcessor::Converter.new(ffmpeg, video_path, video_id)
    converter.logger = LOGGER

    previews = converter.create_preview_imgs
    register_conversion_start(env_id, converter.info, video_id)
    videos = converter.create_web_videos

    LOGGER.info "Registering results for [Video #{video_id}]"
    register_results(env_id, previews, videos, video_id)
    LOGGER.info "Finished processing [Video #{video_id}]"
  rescue IOError => e
    LOGGER.error "FFmpeg ERROR while reading '#{video_path}': #{e.to_s}"
    register_errors(env_id, video_id, e.to_s)
  end
end

unless RAILS_ENV == 'test'
  # Change the working dir to inside the app, so we can call `rails`
  Dir.chdir(__dir__)

  # Process pending files
  %w[ongoing waiting].each do |pool|
    files = Dir[File.join(POOL.path, pool, '*')]
    env_ids = files.map{|f| f.split('/').last }
    env_ids.each{|env_id| process_all_files(env_id, pool.to_sym) }
  end

  trap "SIGTERM" do
    # Gracefully finish all child processes
    Process.kill("TERM", 0)
    Process.exit
  end

  # Start watching the pool dir
  watch_pool
end
