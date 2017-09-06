require 'fileutils'
require 'logger'

module VideoProcessor
  class Logger

    INFO_LOG = "video_processor.out.log"
    ERR_LOG = "video_processor.error.log"

    def initialize(root_path)
      @root_path = root_path
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
      File.join(@root_path, INFO_LOG)
    end

    def error_log_path
      File.join(@root_path, ERR_LOG)
    end

  end
end
