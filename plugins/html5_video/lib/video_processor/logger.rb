require 'fileutils'
require 'logger'

module VideoProcessor
  class Logger

    INFO_LOG = "video_processor.out.log"
    ERR_LOG = "video_processor.error.log"

    def initialize(root_path)
      @root_path = root_path
      create_logs_dir!

      @out_log = ::Logger.new info_log_path
      @err_log = ::Logger.new error_log_path
    end

    def info(msg)
      @out_log.info(msg)
    end

    def error(msg)
      @err_log.error(msg)
    end

    def info_log_path
      File.join(env_dir, INFO_LOG)
    end

    def error_log_path
      File.join(env_dir, ERR_LOG)
    end

    private

    def env_dir
      File.join(@root_path, ENV['RAILS_ENV'] || 'development')
    end

    def create_logs_dir!
      FileUtils.mkdir_p(env_dir) unless File.directory?(env_dir)
    end

  end
end
