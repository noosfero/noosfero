module Html5VideoPlugin::PoolHelper

  def position_for(video)
    pool = VideoProcessor::PoolManager.new(Rails.root.to_s)
    pool.queue_position(video.environment_id, video.id)
  end

end
