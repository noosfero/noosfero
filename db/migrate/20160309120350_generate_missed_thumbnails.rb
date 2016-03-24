class GenerateMissedThumbnails < ActiveRecord::Migration
  def up
    UploadedFile.find_each {|f| f.create_thumbnails if f.thumbnails.empty? }
  end
end
