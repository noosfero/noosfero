class Html5VideoPlugin::CreateVideoPreviewJob

  attr_accessor :file_type, :file_id, :full_filename

  def perform
    return unless file_type.constantize.exists?(file_id)
    ffmpeg = Html5VideoPlugin::Ffmpeg.new

    video = FilePresenter.for file_type.constantize.find(file_id)
    throw "Expected file #{file_id} to be a video" unless video.is_a? FilePresenter::Video

    video_file = full_filename

    response = ffmpeg.video_thumbnail(video_file)

    if response.kind_of?(Hash) && response[:error] && response[:error][:code] != 0
      video.previews = :fail
      video.save!
      Rails.logger.error "ERROR while generating '#{video_file}' image preview: #{response[:error][:message]}"
      return
    end

    video.previews = response
    video.save!
  end

end
