class CreateThumbnailsJob < Struct.new(:class_name, :file_id)
  def perform
    file = class_name.constantize.find(file_id)
    file.create_thumbnails
  end
end
