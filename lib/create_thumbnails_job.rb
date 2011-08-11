class CreateThumbnailsJob < Struct.new(:class_name, :file_id)
  def perform
    return unless class_name.constantize.exists?(file_id)
    file = class_name.constantize.find(file_id)
    file.create_thumbnails
  end
end
