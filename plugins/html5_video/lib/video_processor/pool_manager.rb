require 'fileutils'

# Manages a pool of videos waiting to be converted.
# The pool consists on a directory. Every video is a text file containing the
# full path of the original video file.
module VideoProcessor
  class PoolManager

    # Inside the pool directory, the files will be organized as follows:
    # <pool_path>/<environment_id>/<uploaded_file_id>
    RAILS_ENV = ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development'

    def initialize(root_path)
      @root_path = root_path
    end

    # We use two folders to identify new videos and videos under processing
    def path
      pool_path = File.join(@root_path, 'tmp/html5_video_plugin/pool/')
      File.join(pool_path, RAILS_ENV)
    end

    def waiting_pool
      File.join(path, 'waiting')
    end

    def ongoing_pool
      File.join(path, 'ongoing')
    end

    def failed_pool
      File.join(path, 'failed')
    end

    # Pushes a file to one of the existing pools
    def push(env_id, file_id, file_path, pool=:waiting)
      File.open(pool_file(env_id, file_id, pool), 'w') do |f|
        f.write file_path
      end
    end

    # Moves a file to the ongoing pool, returning the full path of the video
    def assign(env_id, file_id, pool=:waiting)
      begin
        if pool == :waiting
          file = pool_file(env_id, file_id)
          FileUtils.mv(file, pool_file(env_id, file_id, :ongoing))
        end
        video_path = nil
        File.open(pool_file(env_id, file_id, :ongoing)) do |f|
          video_path = f.read
        end
        video_path
      rescue Errno::ENOENT
        nil
      end
    end

    # Removes a file from the ongoing pool, after it was converted successfully
    def pop(env_id, file_id)
      path = pool_file(env_id, file_id, :ongoing)
      File.delete(path)
    end

    def all_files(env_id, pool=:waiting)
      Dir[File.join(pool_for(env_id, pool), '*')].sort
    end

    def init_pools
      [:ongoing, :waiting, :failed].each do |pool|
        path = self.send("#{pool.downcase}_pool")
        FileUtils.mkdir_p(path) unless File.directory? path
      end
    end

    def queue_position(env_id, video_id)
      ids = all_files(env_id).map{ |f| f.split('/').last }
      index = ids.index(video_id.to_s)
      index ? index + 1 : nil
    end

    def is_ongoing?(env_id, video_id)
      ids = all_files(env_id, :ongoing).map{ |f| f.split('/').last }
      return ids.include?(video_id.to_s)
    end

    private

    def pool_for(env_id, pool=:waiting)
      path = self.send("#{pool.downcase}_pool")
      File.join(path, env_id.to_s)
    end

    def pool_file(env_id, file_id, pool=:waiting)
      check_pool_dir(env_id, pool)
      File.join(pool_for(env_id.to_s, pool), file_id.to_s)
    end

    def check_pool_dir(env_id, pool=:waiting)
      path = self.send("#{pool.downcase}_pool")
      pool_dir = pool_for(env_id, pool)
      unless File.directory? pool_dir
        FileUtils.mkdir_p(pool_dir)
      end
    end

  end
end
