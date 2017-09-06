class Html5VideoPlugin::EnqueueVideoConversionJob

  attr_accessor :file_type, :file_id, :full_filename

  def perform
    return unless file_type.constantize.exists?(file_id)
    video = FilePresenter.for file_type.constantize.find(file_id)

    if video.convertible_to_video?
      pool = VideoProcessor::PoolManager.new(Rails.root.to_s)
      pool.push(video.environment_id, file_id, full_filename)
    else
      throw "Expected file #{file_id} to be convertible to video"
    end
  end

end
