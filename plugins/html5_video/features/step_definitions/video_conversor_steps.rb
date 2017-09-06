require 'fileutils'
require_relative '../../script/video_processor_foreground'

Given /^all videos are processed$/ do
  Environment.ids.each do |env_id|
    pool = VideoProcessor::PoolManager.new(Rails.root.to_s)
    pool.all_files(env_id).each do |file|
      video_id = file.split('/').last
      video_path = File.read(file)
      process_video(env_id, video_path, video_id)
      FileUtils.rmtree(pool.path)
    end
  end
end
