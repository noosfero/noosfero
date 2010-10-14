class CreateThumbnailsJob < Struct.new(:class_name, :file_id)
  def perform
    return unless class_name.constantize.exists?(file_id)
    Article.disable_ferret # acts_as_ferret sucks
    file = class_name.constantize.find(file_id)
    file.create_thumbnails
    Article.enable_ferret # acts_as_ferret sucks
  end
end
